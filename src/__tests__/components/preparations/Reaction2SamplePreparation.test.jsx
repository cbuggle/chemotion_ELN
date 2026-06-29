import { cleanup, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import {
  mockCreateActivity,
  mockUpdateSamplePreparation,
  reaction2Process,
  reaction2ProcessWithSteps,
  renderReaction2SamplePreparations,
  renderReaction2Steps,
  resetReaction2Mocks,
} from "../../../testSupport/reaction2TestHelpers";

describe("reaction 2 sample preparations", () => {
  beforeEach(() => {
    resetReaction2Mocks();
  });

  test("creates a sample preparation from the left New Sample button", async () => {
    const preparationOptions = reaction2Process.select_options.samples_preparations;
    const sample = preparationOptions.unprepared_samples[0];
    const preparationType = preparationOptions.preparation_types[0];
    const equipment = preparationOptions.equipment[1];

    renderReaction2SamplePreparations();

    userEvent.click(screen.getByRole("button", { name: "New Sample" }));
    userEvent.selectOptions(screen.getByLabelText("sample_id"), String(sample.value));
    userEvent.selectOptions(screen.getByLabelText("preparations"), preparationType.value);
    userEvent.selectOptions(screen.getByLabelText("equipment"), equipment.value);
    userEvent.type(screen.getByPlaceholderText("Details"), "Dissolved in dry solvent before dosing.");
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockUpdateSamplePreparation).toHaveBeenCalledTimes(1));
    expect(mockUpdateSamplePreparation).toHaveBeenCalledWith(
      reaction2Process.id,
      expect.objectContaining({
        sample_id: sample.value,
        preparations: [preparationType.value],
        equipment: [equipment.value],
        details: "Dissolved in dry solvent before dosing.",
      })
    );
  });

  test("adds a sample to a step and then edits that sample preparation in the left Samples box", async () => {
    const reactionProcess = reaction2ProcessWithSteps(["Charge reagents"]);
    const sample = reactionProcess.select_options.materials.SAMPLE[0];
    const preparationOptions = reactionProcess.select_options.samples_preparations;
    const originalPreparationType = preparationOptions.preparation_types[0];
    const changedPreparationType = preparationOptions.preparation_types[2];
    const equipment = preparationOptions.equipment[1];

    renderReaction2Steps({ reactionProcess });
    userEvent.click(screen.getByRole("button", { name: "New Action" }));
    userEvent.click(screen.getByRole("button", { name: "Add" }));

    await waitFor(() => expect(screen.getByLabelText("sample_id")).toBeInTheDocument());
    userEvent.selectOptions(screen.getByLabelText("sample_id"), String(sample.value));
    userEvent.clear(screen.getByLabelText("Target amount"));
    userEvent.type(screen.getByLabelText("Target amount"), "4.5");
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockCreateActivity).toHaveBeenCalledTimes(1));
    expect(mockCreateActivity).toHaveBeenCalledWith(
      "reaction-2-step-1",
      expect.objectContaining({
        activity_name: "ADD",
        workup: expect.objectContaining({
          sample_id: sample.value,
          sample_name: sample.label,
        }),
      }),
      0
    );

    cleanup();
    mockUpdateSamplePreparation.mockClear();

    const preparedSample = {
      ...sample,
      short_label: sample.label,
      external_label: sample.label,
      name: sample.label,
    };
    const samplePreparation = {
      id: "reaction-2-sample-preparation-1",
      sample_id: sample.value,
      sample: preparedSample,
      preparations: [originalPreparationType.value],
      equipment: [equipment.value],
      details: "Initial sample preparation.",
    };
    const reactionProcessWithPreparedSample = {
      ...reactionProcess,
      samples_preparations: [samplePreparation],
      select_options: {
        ...reactionProcess.select_options,
        samples_preparations: {
          ...preparationOptions,
          prepared_samples: [preparedSample],
          unprepared_samples: preparationOptions.unprepared_samples.filter(
            (candidate) => candidate.value !== sample.value
          ),
        },
      },
    };

    const { container } = renderReaction2SamplePreparations({
      reactionProcess: reactionProcessWithPreparedSample,
    });

    userEvent.click(container.querySelector(".procedure-card--preparation button[aria-label='pen']"));
    userEvent.selectOptions(screen.getByLabelText("preparations"), changedPreparationType.value);
    userEvent.clear(screen.getByPlaceholderText("Details"));
    userEvent.type(screen.getByPlaceholderText("Details"), "Temperature adjusted before dosing.");
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockUpdateSamplePreparation).toHaveBeenCalledTimes(1));
    expect(mockUpdateSamplePreparation).toHaveBeenCalledWith(
      reactionProcess.id,
      expect.objectContaining({
        id: samplePreparation.id,
        sample_id: sample.value,
        preparations: [originalPreparationType.value, changedPreparationType.value],
        equipment: [equipment.value],
        details: "Temperature adjusted before dosing.",
      })
    );
  });
});
