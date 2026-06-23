import fs from "fs";
import path from "path";

import { act } from "react";
import { createRoot } from "react-dom/client";
import { waitFor } from "@testing-library/react";

import ReactionIndex from "../../../components/views/ReactionIndex";

const mockIndex = jest.fn();
const mockSvgImage = jest.fn((reaction) => (
  "http://localhost:3000/images/reactions/" + reaction.reaction_svg_file
));

jest.mock("../../../fetchers/ReactionsFetcher", () => ({
  useReactionsFetcher: () => ({
    index: mockIndex,
    svgImage: mockSvgImage
  })
}));

jest.mock("react-router-dom", () => ({
  ...jest.requireActual("react-router-dom"),
  useNavigate: () => jest.fn()
}));

const fixturePath = path.resolve(process.cwd(), "src/__tests__/fixtures/reactions.json");
const reactionsFixture = JSON.parse(fs.readFileSync(fixturePath, "utf8"));
const fixtureReactions = reactionsFixture.response.json.reactions;

const renderReactionIndex = () => {
  const container = document.createElement("div");
  document.body.appendChild(container);
  const root = createRoot(container);

  act(() => {
    root.render(<ReactionIndex />);
  });

  return {
    container,
    unmount: () => {
      act(() => root.unmount());
      container.remove();
    }
  };
};

describe("ReactionIndex layout", () => {
  let mountedComponent;

  beforeEach(() => {
    jest.clearAllMocks();
    mockIndex.mockResolvedValue(reactionsFixture.response.json);
  });

  afterEach(() => {
    mountedComponent?.unmount();
  });

  test("renders the reactions fixture as a centered grid of reaction cards", async () => {
    mountedComponent = renderReactionIndex();

    await waitFor(() => {
      expect(mountedComponent.container.querySelectorAll(".reaction-index-card")).toHaveLength(8);
    });

    const row = mountedComponent.container.querySelector(".row");
    expect(row).toHaveClass("justify-content-center", "pt-4");

    const columns = mountedComponent.container.querySelectorAll(".row > .col-md-3");
    expect(columns).toHaveLength(fixtureReactions.length);

    const cards = mountedComponent.container.querySelectorAll(".reaction-index-card");
    fixtureReactions.forEach((reaction, index) => {
      const card = cards[index];

      expect(card).toHaveClass("mb-4");
      expect(card.id).toBe("tooltip-reaction-link-" + reaction.id);
      expect(card).toHaveTextContent(reaction.short_label);
      expect(card).toHaveTextContent("ID: " + reaction.id);

      const image = card.querySelector("img");
      expect(image).toHaveAttribute("alt", reaction.short_label);
    });

    fixtureReactions.forEach((reaction) => {
      expect(mockSvgImage).toHaveBeenCalledWith(reaction);
    });
  });

  test("renders the empty-state layout when no reactions are returned", async () => {
    mockIndex.mockResolvedValue({ reactions: [] });
    mountedComponent = renderReactionIndex();

    await waitFor(() => {
      expect(mountedComponent.container).toHaveTextContent("No reactions found for this collection.");
    });
    expect(mountedComponent.container.querySelectorAll(".reaction-index-card")).toHaveLength(0);
  });
});
