import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import {
  mockDeleteProcessStep,
  reaction2ProcessWithSteps,
  renderReaction2Steps,
  resetReaction2Mocks,
} from "../../../testSupport/reaction2TestHelpers";

describe("reaction 2 step deletion", () => {
  beforeEach(() => {
    resetReaction2Mocks();
    jest.spyOn(window, "confirm").mockReturnValue(true);
  });

  afterEach(() => {
    window.confirm.mockRestore();
  });

  test("deletes one step after confirmation", () => {
    const reactionProcess = reaction2ProcessWithSteps([
      "Charge reagents",
      "Warm reaction",
      "Quench mixture",
    ]);

    renderReaction2Steps({ reactionProcess });
    userEvent.click(screen.getAllByRole("button", { name: "trash" })[1]);

    expect(window.confirm).toHaveBeenCalledWith(
      expect.stringContaining("Deleting the ProcessStep")
    );
    expect(mockDeleteProcessStep).toHaveBeenCalledTimes(1);
    expect(mockDeleteProcessStep).toHaveBeenCalledWith("reaction-2-step-2");
  });
});
