import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import {
  mockCreateActivity,
  mockUpdateActivity,
  reaction2Process,
  reaction2Step,
  renderReaction2Steps,
  resetReaction2Mocks,
} from "../../../testSupport/reaction2TestHelpers";

const initialSample = reaction2Process.select_options.materials.SAMPLE[0];

const savedIntermediate = {
  id: 90613,
  value: 90613,
  label: "Step 1 saved intermediate",
  acts_as: "SAMPLE",
  amount: {
    value: 8,
    unit: "mmol",
  },
  unit_amounts: {
    mmol: 8,
    mg: 320,
    ml: 4,
  },
  sample_svg_file: null,
  icon: null,
};

const savedIntermediateActivity = {
  id: "reaction-2-save-intermediate-1",
  value: "reaction-2-save-intermediate-1",
  step_id: "reaction-2-step-1",
  activity_name: "SAVE",
  position: 0,
  workup: {
    intermediate_type: "CRUDE",
    target_amount: savedIntermediate.amount,
    purity: { value: 1 },
    automation_control: { status: "CAN_RUN" },
    automation_mode: reaction2Process.initial_conditions.automation_mode,
    name: savedIntermediate.label,
    short_label: savedIntermediate.label,
    sample_id: savedIntermediate.value,
  },
  sample: {
    id: savedIntermediate.id,
    short_label: savedIntermediate.label,
    external_label: savedIntermediate.label,
    name: savedIntermediate.label,
    sample_svg_file: null,
    target_amount: savedIntermediate.amount,
    amounts: savedIntermediate.unit_amounts,
    intermediate_type: "CRUDE",
  },
  preconditions: reaction2Process.initial_conditions,
};

const targetForStep = (step, savedSampleIds = []) => ({
  value: step.id,
  label: step.label,
  automation_mode: step.automation_mode,
  saved_sample_ids: savedSampleIds,
});

const sampleForCombination = ({ fromStep, fromSample }) => {
  if (!fromSample) {
    return null;
  }

  return fromStep ? savedIntermediate : initialSample;
};

const expectedWorkupFor = ({ fromStep, fromSample, toStep }) => {
  const expected = {};

  if (fromStep) {
    expected.source_step_id = "reaction-2-step-1";
  }

  if (fromSample) {
    const sample = fromStep ? savedIntermediate : initialSample;
    expected.acts_as = sample.acts_as;
    expected.sample_id = sample.value;
    expected.sample_original_amount = sample.amount;
    expected.target_amount = {
      ...sample.amount,
      percentage: 100,
    };

    if (fromStep) {
      expected.source_step_id = "reaction-2-step-1";
    }
  }

  if (toStep) {
    expected.target_step_id = "reaction-2-step-2";
    expected.automation_mode = reaction2Process.initial_conditions.automation_mode;
  }

  return expected;
};

const persistedTransferActivity = (combination) => {
  const sample = sampleForCombination(combination);

  return {
    id: `reaction-2-transfer-${combination.label.replaceAll(" ", "-").toLowerCase()}`,
    value: `reaction-2-transfer-${combination.label.replaceAll(" ", "-").toLowerCase()}`,
    step_id: "reaction-2-step-1",
    activity_name: "TRANSFER",
    position: 1,
    workup: {
      ...expectedWorkupFor(combination),
      target_amount: {
        value: 1,
        unit: "mmol",
        ...(sample && { percentage: 100 }),
      },
      automation_control: { status: "CAN_RUN" },
    },
    ...(sample && {
      sample: {
        id: sample.value,
        short_label: sample.label,
        external_label: sample.label,
        name: sample.label,
        sample_svg_file: null,
        target_amount: sample.amount,
        amounts: sample.unit_amounts,
        intermediate_type: "CRUDE",
      },
    }),
    preconditions: reaction2Process.initial_conditions,
  };
};

const reaction2ProcessWithTransferOptions = (extraSourceActivities = []) => {
  const sourceStep = reaction2Step("Prepare intermediate", 0, {
    activities: [savedIntermediateActivity, ...extraSourceActivities],
  });
  const targetStep = reaction2Step("Receive transfer", 1);
  const transferOptions = {
    ...reaction2Process.select_options.FORMS.TRANSFER,
    transferable_samples: [initialSample, savedIntermediate],
    targets: [
      targetForStep(sourceStep, [savedIntermediate.id]),
      targetForStep(targetStep),
    ],
  };
  const selectOptions = {
    ...reaction2Process.select_options,
    FORMS: {
      ...reaction2Process.select_options.FORMS,
      TRANSFER: transferOptions,
    },
  };

  return {
    ...reaction2Process,
    select_options: selectOptions,
    reaction_process_steps: [
      {
        ...sourceStep,
        select_options: {
          ...sourceStep.select_options,
          saved_samples: [savedIntermediate],
          FORMS: {
            ...sourceStep.select_options.FORMS,
            TRANSFER: transferOptions,
          },
        },
      },
      {
        ...targetStep,
        select_options: {
          ...targetStep.select_options,
          FORMS: {
            ...targetStep.select_options.FORMS,
            TRANSFER: transferOptions,
          },
        },
      },
    ],
  };
};

const openTransferForm = () => {
  renderReaction2Steps({
    reactionProcess: reaction2ProcessWithTransferOptions(),
  });

  userEvent.click(screen.getAllByRole("button", { name: "New Action" })[0]);
  userEvent.click(screen.getByRole("button", { name: "Transfer" }));
};

const openPersistedTransferForm = (combination) => {
  const { container } = renderReaction2Steps({
    reactionProcess: reaction2ProcessWithTransferOptions([
      persistedTransferActivity(combination),
    ]),
  });

  userEvent.click(
    container.querySelectorAll(".activity .procedure-card--action button[aria-label='pen']")[1]
  );
};

const fillTransferForm = ({ fromStep, fromSample, toStep }) => {
  if (fromStep) {
    userEvent.selectOptions(screen.getByLabelText("source_step_id"), "reaction-2-step-1");
  }

  if (fromSample) {
    const sample = fromStep ? savedIntermediate : initialSample;
    userEvent.selectOptions(screen.getByLabelText("sample_id"), String(sample.value));
  }

  if (toStep) {
    userEvent.selectOptions(screen.getByLabelText("target_step_id"), "reaction-2-step-2");
  }
};

const saveTransferForm = () => {
  userEvent.click(screen.getByRole("button", { name: "Save" }));
};

const transferCombinations = [
  { label: "no transfer fields", fromStep: false, fromSample: false, toStep: false, saves: false },
  { label: "From Step only", fromStep: true, fromSample: false, toStep: false, saves: false },
  { label: "From Sample only", fromStep: false, fromSample: true, toStep: false, saves: false },
  { label: "To Step only", fromStep: false, fromSample: false, toStep: true, saves: false },
  { label: "From Step and From Sample only", fromStep: true, fromSample: true, toStep: false, saves: false },
  { label: "From Step to To Step", fromStep: true, fromSample: false, toStep: true, saves: true },
  { label: "From Sample to To Step", fromStep: false, fromSample: true, toStep: true, saves: true },
  { label: "From Step and From Sample to To Step", fromStep: true, fromSample: true, toStep: true, saves: true },
];

describe("reaction 2 TransferForm field combinations", () => {
  beforeEach(() => {
    resetReaction2Mocks();
  });

  test.each(transferCombinations)("$label", async (combination) => {
    openTransferForm();

    fillTransferForm(combination);
    saveTransferForm();

    if (!combination.saves) {
      expect(mockCreateActivity).not.toHaveBeenCalled();
      return;
    }

    await waitFor(() => expect(mockCreateActivity).toHaveBeenCalledTimes(1));
    expect(mockCreateActivity).toHaveBeenCalledWith(
      "reaction-2-step-1",
      expect.objectContaining({
        activity_name: "TRANSFER",
        workup: expect.objectContaining(expectedWorkupFor(combination)),
      }),
      1
    );
  });

  test.each(transferCombinations.filter((combination) => combination.saves))(
    "edits and saves changed data for $label",
    async (combination) => {
      openPersistedTransferForm(combination);

      userEvent.clear(screen.getByLabelText("Target amount"));
      userEvent.type(screen.getByLabelText("Target amount"), "3.5");
      saveTransferForm();

      await waitFor(() => expect(mockUpdateActivity).toHaveBeenCalledTimes(1));
      expect(mockUpdateActivity).toHaveBeenCalledWith(
        expect.objectContaining({
          id: `reaction-2-transfer-${combination.label.replaceAll(" ", "-").toLowerCase()}`,
          activity_name: "TRANSFER",
          workup: expect.objectContaining({
            ...expectedWorkupFor(combination),
            target_amount: expect.objectContaining({
              value: 3.5,
              unit: "mmol",
            }),
          }),
        })
      );
    }
  );
});
