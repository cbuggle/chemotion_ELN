import fs from "fs";
import path from "path";

import { act } from "react";
import { createRoot } from "react-dom/client";
import { waitFor } from "@testing-library/react";

import NotificationContext from "../../contexts/NotificationContext";
import { useReactionsFetcher } from "../../fetchers/ReactionsFetcher";

const mockNavigate = jest.fn();

jest.mock("react-router-dom", () => ({
  ...jest.requireActual("react-router-dom"),
  useNavigate: () => mockNavigate
}));

jest.mock("../../constants", () => ({
  apiHostname: "http://localhost:3000",
  apiBasePath: "http://localhost:3000/api/v1/reaction_process_editor",
  afterSignOutPath: "/",
  generalErrorRedirectPath: "/reactions",
  unauthorizedRedirectPath: "/"
}));

const fixturePath = path.resolve(process.cwd(), "src/__tests__/fixtures/reactions.json");
const reactionsFixture = JSON.parse(fs.readFileSync(fixturePath, "utf8"));

const responseFromFixture = () => ({
  ok: reactionsFixture.response.ok,
  status: reactionsFixture.response.status,
  statusText: reactionsFixture.response.statusText,
  text: () => Promise.resolve(reactionsFixture.response.body)
});

const ReactionsIndexHarness = ({ onData }) => {
  const reactionsFetcher = useReactionsFetcher();

  return (
    <button type="button" onClick={() => reactionsFetcher.index().then(onData)}>
      Fetch reactions
    </button>
  );
};

const renderHarness = ({ onData = jest.fn(), addNotification = jest.fn() } = {}) => {
  const container = document.createElement("div");
  document.body.appendChild(container);
  const root = createRoot(container);

  act(() => {
    root.render(
      <NotificationContext.Provider value={{ addNotification }}>
        <ReactionsIndexHarness onData={onData} />
      </NotificationContext.Provider>
    );
  });

  return {
    addNotification,
    onData,
    button: container.querySelector("button"),
    unmount: () => {
      act(() => root.unmount());
      container.remove();
    }
  };
};

describe("useReactionsFetcher index", () => {
  let mountedComponents;

  beforeEach(() => {
    jest.clearAllMocks();
    localStorage.clear();
    localStorage.setItem("bearer_auth_token", "fixture-token");
    global.fetch = jest.fn().mockResolvedValue(responseFromFixture());
    mountedComponents = [];
  });

  afterEach(() => {
    mountedComponents.forEach((component) => component.unmount());
  });

  test("fetches the reactions index with bearer auth and returns fixture data", async () => {
    const component = renderHarness();
    mountedComponents.push(component);

    await act(async () => component.button.click());

    await waitFor(() => expect(global.fetch).toHaveBeenCalledTimes(1));
    expect(global.fetch).toHaveBeenCalledWith(
      "http://localhost:3000/api/v1/reaction_process_editor/reactions",
      {
        method: "GET",
        headers: {
          Authorization: "Bearer fixture-token",
          Accept: "application/json",
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        }
      }
    );
    expect(component.onData).toHaveBeenCalledWith(reactionsFixture.response.json);
    expect(component.onData.mock.calls[0][0].reactions).toHaveLength(8);
  });
});
