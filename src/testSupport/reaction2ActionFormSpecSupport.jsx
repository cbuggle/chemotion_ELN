import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import { actionTypeClusters } from "../constants/actionTypeClusters";
import { OntologyConstants } from "../constants/OntologyConstants";
import {
  mockCreateActivity,
  reaction2Process,
  reaction2Step,
  renderReaction2Steps,
  resetReaction2Mocks,
} from "./reaction2TestHelpers";

export const actionModes = [
  { label: "automated", value: OntologyConstants.automation_mode.automated },
  { label: "manual", value: OntologyConstants.automation_mode.manual },
];

const actionPanelDefinitions = actionTypeClusters
  .flat()
  .flatMap((cluster) => cluster.actions);

export const actionDefinition = (activityName) =>
  actionPanelDefinitions.find((action) => action.activity.activity_name === activityName);

const fixtureSample = reaction2Process.select_options.materials.SAMPLE[0];
const fixtureMolecularEntity = reaction2Process.select_options.materials.MOLECULAR_ENTITY[0];

const targetForStep = (step, savedSampleIds = []) => ({
  id: step.id,
  value: step.id,
  label: step.label,
  automation_mode: step.automation_mode,
  saved_sample_ids: savedSampleIds,
});

export const createReactionProcessForActionMode = (automationMode) => {
  const sourceStep = reaction2Step("Prepare action inputs", 0, {
    automation_mode: automationMode,
    final_conditions: {
      ...reaction2Process.initial_conditions,
      automation_mode: automationMode,
    },
  });
  const targetStep = reaction2Step("Receive transfer", 1, {
    automation_mode: automationMode,
    final_conditions: {
      ...reaction2Process.initial_conditions,
      automation_mode: automationMode,
    },
  });
  const transferOptions = {
    ...reaction2Process.select_options.FORMS.TRANSFER,
    transferable_samples: [fixtureSample],
    targets: [
      targetForStep(sourceStep),
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

export const renderActionFormForMode = ({ activityName, automationMode, vessels = [] }) => {
  const reactionProcess = createReactionProcessForActionMode(automationMode);
  const { container } = renderReaction2Steps({
    reactionProcess,
    vessels,
  });
  const definition = actionDefinition(activityName);

  userEvent.click(screen.getAllByRole("button", { name: "New Action" })[0]);
  const matchingButtons = screen.getAllByRole("button", {
    name: definition.createLabel,
  });
  userEvent.click(matchingButtons[definition.createLabel === "Chromatography" && activityName === "CHROMATOGRAPHY" ? 1 : 0]);

  return { container, reactionProcess, processStep: reactionProcess.reaction_process_steps[0] };
};

export const changeDescription = (description) => {
  const section = screen.getByText(/^Description\b/).closest(".form-section");
  const openButton = within(section).queryByRole("button", { name: "Change" })
    || within(section).getByRole("button", { name: "Set" });

  userEvent.click(openButton);
  userEvent.clear(within(section).getByRole("textbox"));
  userEvent.type(within(section).getByRole("textbox"), description);
  userEvent.click(within(section).getByRole("button", { name: "Set" }));
};

export const fillCommonActionFields = (activityName, modeLabel) => {
  changeDescription(`${activityName} ${modeLabel} happy path`);
};

export const fillIfPresent = {
  select: (label, value) => {
    const input = screen.queryAllByLabelText(label)[0];
    const hasOption = input && Array.from(input.options).some((option) => option.value === String(value));
    if (hasOption) userEvent.selectOptions(input, String(value));
  },
  text: (label, value) => {
    const input = screen.queryByLabelText(label) || screen.queryByPlaceholderText(label);
    if (input) {
      userEvent.clear(input);
      userEvent.type(input, String(value));
    }
  },
  metric: (label, value) => {
    const input = screen.queryAllByLabelText(label)[0];
    if (input) {
      userEvent.clear(input);
      userEvent.type(input, String(value));
    }
  },
};

export const selectFixtureSample = () => {
  fillIfPresent.select("sample_id", fixtureSample.value);
};

export const selectFixtureSampleIcon = () => {
  const input = screen.queryAllByLabelText("Molecular Entity")[0];
  if (input) userEvent.selectOptions(input, String(fixtureSample.value));
};

export const selectFixtureMolecularEntity = (index = 0) => {
  const input = screen.queryAllByLabelText("Molecular Entity")[index];
  if (input) userEvent.selectOptions(input, String(fixtureMolecularEntity.value));
};

export const targetTransferToSecondStep = () => {
  fillIfPresent.select("target_step_id", "reaction-2-step-2");
};

export const saveActionForm = () => {
  userEvent.click(screen.getByRole("button", { name: "Save" }));
};

export const expectCreatedAction = async ({
  activityName,
  automationMode,
  expectedWorkup = {},
  expectedActivity = {},
}) => {
  await waitFor(() => expect(mockCreateActivity).toHaveBeenCalledTimes(1));
  expect(mockCreateActivity).toHaveBeenCalledWith(
    "reaction-2-step-1",
    expect.objectContaining({
      activity_name: activityName,
      ...expectedActivity,
      workup: expect.objectContaining({
        description: expect.any(String),
        automation_mode: automationMode,
        ...expectedWorkup,
      }),
    }),
    0
  );
};

export const expectInvalidTransferDoesNotSave = () => {
  saveActionForm();
  expect(mockCreateActivity).not.toHaveBeenCalled();
  expect(screen.getByRole("button", { name: "Save" })).toBeInTheDocument();
};

export const runActionFormSpecs = ({
  activityName,
  fillHappyPath = () => {},
  expectedWorkup = () => ({}),
  expectedActivity = () => ({}),
  assertErrorPath,
  vessels = [],
}) => {
  describe(`reaction 2 ${activityName} ActionForm`, () => {
    beforeEach(() => {
      resetReaction2Mocks();
    });

    test.each(actionModes)(
      "creates a happy path action in $label mode",
      async ({ label, value }) => {
        renderActionFormForMode({ activityName, automationMode: value, vessels });

        fillCommonActionFields(activityName, label);
        fillHappyPath({ automationMode: value, modeLabel: label });
        saveActionForm();

        await expectCreatedAction({
          activityName,
          automationMode: value,
          expectedWorkup: expectedWorkup({ automationMode: value, modeLabel: label }),
          expectedActivity: expectedActivity({ automationMode: value, modeLabel: label }),
        });
      }
    );

    test.each(actionModes)(
      "covers the error path in $label mode",
      ({ value }) => {
        renderActionFormForMode({ activityName, automationMode: value, vessels });

        if (assertErrorPath) {
          assertErrorPath({ automationMode: value });
        } else {
          saveActionForm();
          expect(mockCreateActivity).toHaveBeenCalledTimes(1);
        }
      }
    );
  });
};
