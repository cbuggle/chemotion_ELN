import fs from "fs";
import path from "path";

import { act } from "react";
import { createRoot } from "react-dom/client";
import { waitFor } from "@testing-library/react";

import { SelectOptions } from "../../../../../contexts/SelectOptions";
import { StepLock } from "../../../../../contexts/StepLock";
import { StepSelectOptions } from "../../../../../contexts/StepSelectOptions";
import { SubFormController } from "../../../../../contexts/SubFormController";
import { VesselOptions } from "../../../../../contexts/VesselOptions";

import ActionForm from "../../../../../components/activities/forms/actions/ActionForm";

jest.mock("../../../../../components/utilities/TooltipButton", () => () => null);

jest.mock("../../../../../components/utilities/ChromatographyPoolingFormModal", () => () => (
  <div data-testid="chromatography-pooling-form-modal" />
));

jest.mock("../../../../../components/utilities/AmountInputSet", () => ({
  __esModule: true,
  default: ({ amount }) => (
    <section data-testid="amount-input-set">
      Amount {amount?.value ?? "unspecified"} {amount?.unit}
    </section>
  )
}));

jest.mock("../../../../../components/activities/forms/formgroups/MetricsInputFormGroup", () => ({
  __esModule: true,
  default: ({ label, metricName, amount }) => (
    <section data-testid={"metric-input-" + metricName}>
      {label || metricName} {amount?.value ?? "unspecified"} {amount?.unit}
    </section>
  )
}));

jest.mock("../../../../../components/activities/forms/formgroups/AutomationControlFormGroup", () => ({
  __esModule: true,
  default: ({ automationControl }) => (
    <section data-testid="automation-control-form-group">
      Automation: {automationControl?.status}
    </section>
  )
}));

jest.mock("../../../../../components/vesselables/VesselableFormSection", () => ({
  __esModule: true,
  default: ({ reactionProcessVessel, automationMode }) => (
    <section data-testid="vesselable-form-section">
      Vessel section
      <span data-testid="vessel-automation-mode">{automationMode || ""}</span>
      <span data-testid="vessel-id">{reactionProcessVessel?.id || ""}</span>
    </section>
  )
}));

const fixturePath = path.resolve(process.cwd(), "src/__tests__/fixtures/reaction_1_reaction_process.json");
const reactionProcessFixture = JSON.parse(fs.readFileSync(fixturePath, "utf8"));
const reactionProcess = reactionProcessFixture.response.json.reaction_process;
const processStep = reactionProcess.reaction_process_steps[0];
const saveActivities = processStep.activities;

const subFormController = {
  anyBlockingSubformOpen: () => false,
  isCurrentOpen: () => false,
  isBlocked: () => false,
  toggleSubForm: jest.fn(),
  closeSubForm: jest.fn(),
  closeSubFormArray: jest.fn(),
  openSubForm: jest.fn()
};

const renderActionForm = ({
  activity = saveActivities[0],
  onWorkupChange = jest.fn(),
  onSave = jest.fn(),
  onCancel = jest.fn(),
  onChangeDuration = jest.fn(),
  onChangeVessel = jest.fn()
} = {}) => {
  const container = document.createElement("div");
  document.body.appendChild(container);
  const root = createRoot(container);

  act(() => {
    root.render(
      <SubFormController.Provider value={subFormController}>
        <StepLock.Provider value={false}>
          <SelectOptions.Provider value={reactionProcess.select_options}>
            <StepSelectOptions.Provider value={processStep.select_options}>
              <VesselOptions.Provider value={reactionProcess.reaction_process_vessels}>
                <ActionForm
                  activity={activity}
                  preconditions={activity.preconditions}
                  onCancel={onCancel}
                  onSave={onSave}
                  onWorkupChange={onWorkupChange}
                  onChangeDuration={onChangeDuration}
                  onChangeVessel={onChangeVessel}
                  processStep={processStep}
                />
              </VesselOptions.Provider>
            </StepSelectOptions.Provider>
          </SelectOptions.Provider>
        </StepLock.Provider>
      </SubFormController.Provider>
    );
  });

  return {
    container,
    onWorkupChange,
    onSave,
    onCancel,
    onChangeDuration,
    onChangeVessel,
    unmount: () => {
      act(() => root.unmount());
      container.remove();
    }
  };
};

const valuesForNamedInputs = (container, name) => (
  Array.from(container.querySelectorAll(`[name="${name}"]`)).map((input) => input.value)
);

const textControlValues = (container) => (
  Array.from(container.querySelectorAll("input, textarea")).map((input) => input.value)
);

describe("ActionForm variants used by reaction 1 fixture", () => {
  let mountedComponent;

  afterEach(() => {
    mountedComponent?.unmount();
    jest.clearAllMocks();
  });

  test("the reaction 1 fixture currently exercises the SAVE ActionForm variant", () => {
    expect([...new Set(saveActivities.map((activity) => activity.activity_name))]).toEqual(["SAVE"]);
    expect(saveActivities).toHaveLength(4);
  });

  test("renders each persisted SAVE activity from the fixture with its core fields", async () => {
    for (const activity of saveActivities) {
      mountedComponent = renderActionForm({ activity });

      await waitFor(() => {
        expect(mountedComponent.container.querySelector(".activity-form.action-form")).toBeInTheDocument();
      });

      expect(mountedComponent.container).toHaveTextContent("Molecular Entities");
      expect(mountedComponent.container).toHaveTextContent("Name");
      expect(mountedComponent.container).toHaveTextContent("Short Label");
      expect(mountedComponent.container).toHaveTextContent("Origin");
      expect(mountedComponent.container).toHaveTextContent("Sample Type");
      expect(mountedComponent.container).toHaveTextContent("Display in ELN");
      expect(mountedComponent.container).toHaveTextContent("Description -");

      expect(textControlValues(mountedComponent.container)).toContain(activity.workup.name);
      expect(textControlValues(mountedComponent.container)).toContain(activity.workup.short_label);
      expect(mountedComponent.container).toHaveTextContent(String(activity.workup.purity.value));
      expect(mountedComponent.container).toHaveTextContent(activity.workup.target_amount.unit);
      activity.workup.target_amount.value &&
        expect(mountedComponent.container).toHaveTextContent(String(activity.workup.target_amount.value));

      expect(mountedComponent.container.querySelector('[data-testid="vesselable-form-section"]')).toBeInTheDocument();
      expect(mountedComponent.container.querySelector('[data-testid="vessel-automation-mode"]')).toHaveTextContent(
        activity.workup.automation_mode
      );

      mountedComponent.unmount();
      mountedComponent = undefined;
    }
  });

  test("initializes shared action metadata from the activity and process step", async () => {
    const onWorkupChange = jest.fn();
    mountedComponent = renderActionForm({ activity: saveActivities[0], onWorkupChange });

    await waitFor(() => {
      expect(onWorkupChange).toHaveBeenCalledWith({
        name: "class",
        value: undefined
      });
    });
    expect(onWorkupChange).toHaveBeenCalledWith({
      name: "automation_mode",
      value: processStep.automation_mode
    });
  });

  test("renders SAVE amount variants from the fixture", async () => {
    mountedComponent = renderActionForm({ activity: saveActivities[0] });
    await waitFor(() => expect(mountedComponent.container).toHaveTextContent("ml"));
    expect(mountedComponent.container).not.toHaveTextContent("20 ml");
    mountedComponent.unmount();

    mountedComponent = renderActionForm({ activity: saveActivities[1] });
    await waitFor(() => expect(mountedComponent.container).toHaveTextContent("20"));
    expect(mountedComponent.container).toHaveTextContent("ml");
    mountedComponent.unmount();

    mountedComponent = renderActionForm({ activity: saveActivities[2] });
    await waitFor(() => expect(mountedComponent.container).toHaveTextContent("20"));
    expect(mountedComponent.container).toHaveTextContent("mg");
    mountedComponent.unmount();

    mountedComponent = renderActionForm({ activity: saveActivities[3] });
    await waitFor(() => expect(mountedComponent.container).toHaveTextContent("25"));
    expect(mountedComponent.container).toHaveTextContent("mmol");
  });

  test("renders the purification-origin branch when a SAVE workup uses purification origin", async () => {
    const purificationActivity = {
      ...saveActivities[0],
      workup: {
        ...saveActivities[0].workup,
        sample_origin_type: "PURIFICATION",
        sample_origin_action_id: "purification-action",
        sample_origin_purification_step: {
          label: "Purification step 1",
          amount: { value: 12, unit: "ml" },
          solvents: [{ label: "Water" }, { label: "Ethyl acetate" }]
        }
      }
    };
    const purificationOrigin = {
      value: "purification-action",
      label: "Chromatography",
      activity_name: "CHROMATOGRAPHY",
      purification_steps: [purificationActivity.workup.sample_origin_purification_step]
    };
    const stepOptions = {
      ...processStep.select_options,
      FORMS: {
        ...processStep.select_options.FORMS,
        SAVE: {
          origins: [purificationOrigin]
        }
      }
    };

    const container = document.createElement("div");
    document.body.appendChild(container);
    const root = createRoot(container);
    const onWorkupChange = jest.fn();

    act(() => {
      root.render(
        <SubFormController.Provider value={subFormController}>
          <StepLock.Provider value={false}>
            <SelectOptions.Provider value={reactionProcess.select_options}>
              <StepSelectOptions.Provider value={stepOptions}>
                <VesselOptions.Provider value={reactionProcess.reaction_process_vessels}>
                  <ActionForm
                    activity={purificationActivity}
                    preconditions={purificationActivity.preconditions}
                    onCancel={jest.fn()}
                    onSave={jest.fn()}
                    onWorkupChange={onWorkupChange}
                    onChangeDuration={jest.fn()}
                    onChangeVessel={jest.fn()}
                    processStep={processStep}
                  />
                </VesselOptions.Provider>
              </StepSelectOptions.Provider>
            </SelectOptions.Provider>
          </StepLock.Provider>
        </SubFormController.Provider>
      );
    });

    mountedComponent = {
      container,
      unmount: () => {
        act(() => root.unmount());
        container.remove();
      }
    };

    await waitFor(() => {
      expect(container).toHaveTextContent("Purification Step");
    });
    expect(container).toHaveTextContent("Activity");
    expect(container).toHaveTextContent("Solvents");
    expect(container).toHaveTextContent("Water, Ethyl acetate");
    expect(container).toHaveTextContent("Amount");
    expect(container).toHaveTextContent("ml");
    expect(onWorkupChange).toHaveBeenCalledWith({
      name: "solvents_amount",
      value: { value: 12, unit: "ml" }
    });
  });
});
