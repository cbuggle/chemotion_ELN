import fs from "fs";
import path from "path";

import React from "react";
import { render } from "@testing-library/react";

import NotificationContext from "../contexts/NotificationContext";
import { SelectOptions } from "../contexts/SelectOptions";
import { VesselOptions } from "../contexts/VesselOptions";
import SamplePreparationColumnCard from "../components/preparations/SamplePreparationColumnCard";
import VesselPreparationColumnCard from "../components/preparations/VesselPreparationColumnCard";
import StepsContainer from "../components/steps/StepsContainer";

global.structuredClone ||= (value) => JSON.parse(JSON.stringify(value));

export const mockCreateProcessStep = jest.fn();
export const mockUpdateProcessStep = jest.fn();
export const mockDeleteProcessStep = jest.fn();
export const mockCreateActivity = jest.fn();
export const mockUpdateActivity = jest.fn();
export const mockUpdateSamplePreparation = jest.fn();
export const mockDeleteSamplePreparation = jest.fn();
export const mockUpdateReactionProcessVessel = jest.fn();
export const mockUpdateUserDefaultConditions = jest.fn(() => Promise.resolve());
export const mockUpdateReactionDefaultConditions = jest.fn(() => Promise.resolve());

jest.mock("../fetchers/ReactionsFetcher", () => ({
  useReactionsFetcher: () => ({
    createProcessStep: mockCreateProcessStep,
    updateProcessStep: mockUpdateProcessStep,
    deleteProcessStep: mockDeleteProcessStep,
    createActivity: mockCreateActivity,
    updateProcessStepPosition: jest.fn(),
    deleteActivity: jest.fn(),
    updateActivity: mockUpdateActivity,
    updateActivityPosition: jest.fn(),
    createFractionActivities: jest.fn(),
    updateSamplePreparation: mockUpdateSamplePreparation,
    deleteSamplePreparation: mockDeleteSamplePreparation,
    updateReactionProcessVessel: mockUpdateReactionProcessVessel,
    updateUserDefaultConditions: mockUpdateUserDefaultConditions,
    updateReactionDefaultConditions: mockUpdateReactionDefaultConditions,
  }),
}));

jest.mock("react-dnd", () => ({
  DndProvider: ({ children }) => children,
  useDrag: () => [{ isDragging: false }, jest.fn(), jest.fn()],
  useDrop: () => [{ isOver: false }, jest.fn()],
}));

jest.mock("react-dnd-html5-backend", () => ({
  HTML5Backend: {},
}));

jest.mock("@fortawesome/react-fontawesome", () => ({
  FontAwesomeIcon: () => null,
}));

jest.mock("../components/utilities/IconButton", () => ({
  __esModule: true,
  default: ({ icon, onClick, disabled }) => (
    <button aria-label={icon} disabled={disabled} onClick={onClick} type="button">
      {icon}
    </button>
  ),
}));

jest.mock("../components/activities/forms/formgroups/AutoComplete", () => ({
  __esModule: true,
  default: ({ label, value, onChange, domId }) => (
    <label htmlFor={domId}>
      {label}
      <input
        aria-label={label}
        defaultValue={value}
        id={domId}
        onChange={(event) => onChange(event.target.value)}
      />
    </label>
  ),
}));

jest.mock("../components/vesselables/VesselableQuickSelector", () => ({
  __esModule: true,
  default: ({ onSelectVesselable, vesselOptions = [] }) => (
    <button
      disabled={vesselOptions.length === 0}
      onClick={() => onSelectVesselable(vesselOptions[0])}
      type="button"
    >
      {vesselOptions[0]?.label || "No vessel"}
    </button>
  ),
}));

jest.mock("react-select", () => ({
  __esModule: true,
  default: ({ name, options = [], value, onChange, isMulti, placeholder }) => {
    const currentValue = isMulti
      ? (value || []).map((option) => String(option.value))
      : value?.value === undefined
        ? ""
        : String(value.value);

    return (
      <select
        aria-label={name || placeholder || "select"}
        multiple={!!isMulti}
        name={name}
        onChange={(event) => {
          if (isMulti) {
            const selectedOptions = Array.from(event.target.selectedOptions).map((option) =>
              options.find((candidate) => String(candidate.value) === option.value)
            );
            onChange(selectedOptions);
          } else {
            onChange(options.find((option) => String(option.value) === event.target.value));
          }
        }}
        value={currentValue}
      >
        <option value="">Select...</option>
        {options.map((option) => (
          <option key={String(option.value)} value={String(option.value)}>
            {option.label}
          </option>
        ))}
      </select>
    );
  },
}));

jest.mock("../components/utilities/AmountInputSet", () => ({
  __esModule: true,
  default: ({ amount = {}, onChangeAmount }) => (
    <fieldset>
      <label>
        Target amount
        <input
          aria-label="Target amount"
          defaultValue={amount.value ?? ""}
          onChange={(event) =>
            onChangeAmount({
              ...amount,
              value: Number(event.target.value),
              unit: amount.unit || "mmol",
            })
          }
        />
      </label>
      <label>
        Target amount unit
        <select
          aria-label="Target amount unit"
          defaultValue={amount.unit || "mmol"}
          onChange={(event) =>
            onChangeAmount({
              ...amount,
              unit: event.target.value,
            })
          }
        >
          <option value="mmol">mmol</option>
          <option value="mg">mg</option>
          <option value="ml">ml</option>
        </select>
      </label>
    </fieldset>
  ),
}));

jest.mock("../components/utilities/SamplesIconSelect", () => ({
  __esModule: true,
  default: ({ options = [], onChange }) => (
    <select
      aria-label="Molecular Entity"
      onChange={(event) =>
        onChange([options.find((option) => String(option.value) === event.target.value)])
      }
    >
      <option value="">Select...</option>
      {options.map((option) => (
        <option key={String(option.value)} value={String(option.value)}>
          {option.label}
        </option>
      ))}
    </select>
  ),
}));

jest.mock("../components/activities/forms/formgroups/MetricsInputFormGroup", () => ({
  __esModule: true,
  default: ({ metricName, amount, onChange }) => (
    <label>
      {metricName}
      <input
        aria-label={metricName}
        defaultValue={amount?.value ?? ""}
        onChange={(event) =>
          onChange({
            ...amount,
            value: Number(event.target.value),
            unit: amount?.unit,
          })
        }
      />
    </label>
  ),
}));

jest.mock("../components/utilities/ChromatographyPoolingFormModal", () => () => null);
jest.mock("../components/utilities/TooltipButton", () => () => null);

const fixturePath = path.resolve(process.cwd(), "src/__tests__/fixtures/reaction_2_reaction_process.json");
const reaction2Fixture = JSON.parse(fs.readFileSync(fixturePath, "utf8"));

export const reaction2Process = reaction2Fixture.response.json.reaction_process;

export const resetReaction2Mocks = () => {
  mockCreateProcessStep.mockClear();
  mockUpdateProcessStep.mockClear();
  mockDeleteProcessStep.mockClear();
  mockCreateActivity.mockClear();
  mockUpdateActivity.mockClear();
  mockUpdateSamplePreparation.mockClear();
  mockDeleteSamplePreparation.mockClear();
  mockUpdateReactionProcessVessel.mockClear();
  mockUpdateUserDefaultConditions.mockClear();
  mockUpdateUserDefaultConditions.mockImplementation(() => Promise.resolve());
  mockUpdateReactionDefaultConditions.mockClear();
  mockUpdateReactionDefaultConditions.mockImplementation(() => Promise.resolve());
};

export const reaction2Step = (name, position = 0, overrides = {}) => {
  const id = `reaction-2-step-${position + 1}`;

  return {
    id,
    value: id,
    name,
    position,
    locked: null,
    reaction_process_id: reaction2Process.id,
    reaction_id: 2,
    label: `${position + 1}/${position + 1} ${name}`,
    final_conditions: reaction2Process.initial_conditions,
    select_options: {
      added_materials: [],
      mounted_equipment: [],
      saved_samples: [],
      FORMS: {
        ...reaction2Process.select_options.FORMS,
        SAVE: {
          ...reaction2Process.select_options.FORMS.SAVE,
          origins: [],
        },
        EVAPORATION: {
          ...reaction2Process.select_options.FORMS.EVAPORATION,
          removable_samples: {
            FROM_REACTION: [],
            FROM_REACTION_STEP: [],
            FROM_SAMPLE: [],
            DIVERSE_SOLVENTS: [],
            STEPWISE: [],
            FROM_METHOD: [],
            SOLVENT_FROM_FRACTION: [],
          },
        },
      },
    },
    automation_control: { status: "STEP_CAN_RUN" },
    automation_mode: reaction2Process.initial_conditions.automation_mode,
    activities: [],
    reaction_process_vessel: null,
    ...overrides,
  };
};

export const reaction2ProcessWithSteps = (stepNames) => ({
  ...reaction2Process,
  reaction_process_steps: stepNames.map((name, index) => reaction2Step(name, index)),
});

export const fixtureVessel = {
  id: "fixture-vessel-template-1",
  value: "fixture-vessel-template-1",
  label: "VT-100 Round Bottom Flask",
  short_label: "VT-100",
  name: "Round Bottom Flask",
  vesselable_type: "VesselTemplate",
  vessel_type: "flask",
  material_type: "glass",
  volume_amount: 100,
  volume_unit: "ML",
  automation_modes: [reaction2Process.initial_conditions.automation_mode],
};

export const renderReaction2Steps = ({
  reactionProcess = reaction2Process,
  vessels = [],
} = {}) => render(
  <NotificationContext.Provider value={{ addNotification: jest.fn() }}>
    <SelectOptions.Provider value={reactionProcess.select_options}>
      <VesselOptions.Provider value={vessels}>
        <StepsContainer reactionProcess={reactionProcess} />
      </VesselOptions.Provider>
    </SelectOptions.Provider>
  </NotificationContext.Provider>
);

export const renderReaction2SamplePreparations = ({
  reactionProcess = reaction2Process,
} = {}) => render(
  <NotificationContext.Provider value={{ addNotification: jest.fn() }}>
    <SelectOptions.Provider value={reactionProcess.select_options}>
      <SamplePreparationColumnCard reactionProcess={reactionProcess} />
    </SelectOptions.Provider>
  </NotificationContext.Provider>
);

export const renderReaction2VesselPreparations = ({
  reactionProcess = reaction2Process,
  vessels = [],
} = {}) => render(
  <NotificationContext.Provider value={{ addNotification: jest.fn() }}>
    <SelectOptions.Provider value={reactionProcess.select_options}>
      <VesselOptions.Provider value={vessels}>
        <VesselPreparationColumnCard reactionProcess={reactionProcess} />
      </VesselOptions.Provider>
    </SelectOptions.Provider>
  </NotificationContext.Provider>
);
