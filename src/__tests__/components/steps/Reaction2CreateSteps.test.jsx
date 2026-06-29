import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import {
  mockCreateProcessStep,
  reaction2Process,
  renderReaction2Steps,
  resetReaction2Mocks,
} from "../../../testSupport/reaction2TestHelpers";

describe("reaction 2 step creation", () => {
  beforeEach(() => {
    resetReaction2Mocks();
  });

  test("uses the New Step button to create three named steps", () => {
    renderReaction2Steps();

    ["Charge reagents", "Warm reaction", "Quench mixture"].forEach((stepName) => {
      userEvent.click(screen.getByRole("button", { name: "New Step" }));
      userEvent.clear(screen.getByLabelText("Name"));
      userEvent.type(screen.getByLabelText("Name"), stepName);
      userEvent.click(screen.getByRole("button", { name: "Save" }));
    });

    expect(mockCreateProcessStep).toHaveBeenCalledTimes(3);
    expect(mockCreateProcessStep).toHaveBeenNthCalledWith(
      1,
      reaction2Process.id,
      expect.objectContaining({ name: "Charge reagents" })
    );
    expect(mockCreateProcessStep).toHaveBeenNthCalledWith(
      2,
      reaction2Process.id,
      expect.objectContaining({ name: "Warm reaction" })
    );
    expect(mockCreateProcessStep).toHaveBeenNthCalledWith(
      3,
      reaction2Process.id,
      expect.objectContaining({ name: "Quench mixture" })
    );
  });
});
