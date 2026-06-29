import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import {
  mockCreateActivity,
  mockUpdateActivity,
  reaction2Process,
  reaction2Step,
  reaction2ProcessWithSteps,
  renderReaction2Steps,
  resetReaction2Mocks,
} from "../../../testSupport/reaction2TestHelpers";

describe("reaction 2 Add Sample action", () => {
  beforeEach(() => {
    resetReaction2Mocks();
  });

  test("creates a new Add Sample action with selected sample and amount values", async () => {
    const reactionProcess = reaction2ProcessWithSteps(["Charge reagents"]);
    const sample = reactionProcess.select_options.materials.SAMPLE[0];

    renderReaction2Steps({ reactionProcess });
    userEvent.click(screen.getByRole("button", { name: "New Action" }));
    userEvent.click(screen.getByRole("button", { name: "Add" }));

    await waitFor(() => expect(screen.getByLabelText("sample_id")).toBeInTheDocument());
    userEvent.selectOptions(screen.getByLabelText("sample_id"), String(sample.value));
    userEvent.clear(screen.getByLabelText("Target amount"));
    userEvent.type(screen.getByLabelText("Target amount"), "12.5");
    userEvent.selectOptions(screen.getByLabelText("Target amount unit"), "mmol");
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockCreateActivity).toHaveBeenCalledTimes(1));
    expect(mockCreateActivity).toHaveBeenCalledWith(
      "reaction-2-step-1",
      expect.objectContaining({
        activity_name: "ADD",
        workup: expect.objectContaining({
          acts_as: "SAMPLE",
          sample_id: sample.value,
          sample_name: sample.label,
          target_amount: { value: 12.5, unit: "mmol" },
        }),
      }),
      0
    );
  });

  test("edits and saves changed Add Sample action data", async () => {
    const sample = reaction2Process.select_options.materials.SAMPLE[0];
    const { container } = renderReaction2Steps({
      reactionProcess: {
        ...reaction2Process,
        reaction_process_steps: [
          reaction2Step("Charge reagents", 0, {
            activities: [
              {
                id: "reaction-2-add-activity",
                value: "reaction-2-add-activity",
                step_id: "reaction-2-step-1",
                activity_name: "ADD",
                position: 0,
                workup: {
                  acts_as: sample.acts_as,
                  sample_id: sample.value,
                  sample_name: sample.label,
                  target_amount: { value: 1, unit: "mmol" },
                  automation_control: { status: "CAN_RUN" },
                  automation_mode: reaction2Process.initial_conditions.automation_mode,
                },
                sample: {
                  id: sample.value,
                  short_label: sample.label,
                  external_label: sample.label,
                  name: sample.label,
                  sample_svg_file: null,
                  target_amount: sample.amount,
                  amounts: sample.unit_amounts,
                },
                preconditions: reaction2Process.initial_conditions,
              },
            ],
          }),
        ],
      },
    });

    userEvent.click(
      container.querySelector(".activity .procedure-card--action button[aria-label='pen']")
    );
    userEvent.clear(screen.getByLabelText("Target amount"));
    userEvent.type(screen.getByLabelText("Target amount"), "9.75");
    userEvent.selectOptions(screen.getByLabelText("Target amount unit"), "mg");
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockUpdateActivity).toHaveBeenCalledTimes(1));
    expect(mockUpdateActivity).toHaveBeenCalledWith(
      expect.objectContaining({
        id: "reaction-2-add-activity",
        activity_name: "ADD",
        workup: expect.objectContaining({
          sample_id: sample.value,
          target_amount: {
            value: 9.75,
            unit: "mg",
          },
        }),
      })
    );
  });
});
