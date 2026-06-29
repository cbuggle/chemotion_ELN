import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import {
  mockDownloadClap,
  reaction2Process,
  resetReaction2Mocks,
} from "../../../testSupport/reaction2TestHelpers";
import ClapDownloadButton from "../../../components/reactions/navbar/ClapDownloadButton";

describe("reaction 2 CLAP/JSON download", () => {
  beforeEach(() => {
    resetReaction2Mocks();
    window.URL.createObjectURL = jest.fn(() => "blob:fixture-clap-json");
    window.URL.revokeObjectURL = jest.fn();
  });

  test("downloads the reaction as a CLAP/JSON file", async () => {
    const blob = new Blob(["{\"reaction\":\"fixture\"}"], { type: "application/json" });
    const anchorClick = jest.spyOn(HTMLAnchorElement.prototype, "click").mockImplementation(() => {});
    const appendChild = jest.spyOn(document.body, "appendChild");
    const removeChild = jest.spyOn(document.body, "removeChild");

    mockDownloadClap.mockResolvedValue({
      headers: {
        get: jest.fn(() => "attachment; filename*=UTF-8''reaction-2-clap.json"),
      },
      blob: jest.fn(() => Promise.resolve(blob)),
    });

    render(<ClapDownloadButton reactionProcessId={reaction2Process.id} />);

    userEvent.click(screen.getByRole("button", { name: "download" }));

    await waitFor(() => expect(mockDownloadClap).toHaveBeenCalledWith(reaction2Process.id));
    await waitFor(() => expect(anchorClick).toHaveBeenCalledTimes(1));

    const downloadedAnchor = appendChild.mock.calls
      .map(([node]) => node)
      .find((node) => node.tagName === "A");

    expect(window.URL.createObjectURL).toHaveBeenCalledWith(blob);
    expect(downloadedAnchor).toHaveAttribute("href", "blob:fixture-clap-json");
    expect(downloadedAnchor).toHaveAttribute("download", "reaction-2-clap.json");
    expect(removeChild).toHaveBeenCalledWith(downloadedAnchor);
    expect(window.URL.revokeObjectURL).toHaveBeenCalledWith("blob:fixture-clap-json");

    anchorClick.mockRestore();
    appendChild.mockRestore();
    removeChild.mockRestore();
  });
});
