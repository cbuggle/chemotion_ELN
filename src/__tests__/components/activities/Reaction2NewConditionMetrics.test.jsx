import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import { conditionFormMetricNames } from "../../../constants/formMetrics";
import {
  mockCreateActivity,
  mockUpdateActivity,
  reaction2Process,
  reaction2Step,
  reaction2ProcessWithSteps,
  renderReaction2Steps,
  resetReaction2Mocks,
} from "../../../testSupport/reaction2TestHelpers";

const setMetricValue = (metricName, value) => {
  const input = screen.getByLabelText(metricName);

  userEvent.clear(input);
  userEvent.type(input, String(value));
};

const openMetricSubform = (label) => {
  const section = screen.getByText(new RegExp(`^${label}\\b`)).closest(".form-section");
  const openButton = within(section).getByRole("button", { name: /^(Set|Change)$/ });

  userEvent.click(openButton);

  return section;
};

const setSubform = (section) => {
  userEvent.click(within(section).getByRole("button", { name: "Set" }));
};

const openNewCondition = () => {
  renderReaction2Steps({
    reactionProcess: reaction2ProcessWithSteps(["Charge reagents"]),
  });

  userEvent.click(screen.getByRole("button", { name: "Change Condition" }));
};

const saveCondition = async () => {
  userEvent.click(screen.getByRole("button", { name: "Save" }));

  await waitFor(() => expect(mockCreateActivity).toHaveBeenCalledTimes(1));
};

const selectFirstConditionEquipment = (metricName) => {
  const equipment =
    reaction2Process.select_options.FORMS.CONDITION.equipment[metricName][0];

  userEvent.selectOptions(screen.getByLabelText("equipment"), equipment.value);

  return equipment;
};

const initialWorkupForMetric = {
  TEMPERATURE: {
    TEMPERATURE: {
      value: 21,
      unit: "CELSIUS",
      additional_information: "AMBIENT",
    },
    EQUIPMENT: { value: [] },
  },
  PH: {
    PH: {
      value: 7,
      unit: "PH",
      additional_information: "PH_STRIPE",
    },
    EQUIPMENT: { value: [] },
  },
  PRESSURE: {
    PRESSURE: {
      value: 1013,
      unit: "MBAR",
      additional_information: "",
    },
    EQUIPMENT: { value: [] },
  },
  IRRADIATION: {
    IRRADIATION: {
      value: 420,
      unit: "NM",
      additional_information: "LAMP",
      power: {
        value: 20,
        unit: "WATT",
      },
    },
    EQUIPMENT: { value: [] },
  },
  MOTION: {
    MOTION: {
      speed: {
        value: 250,
        unit: "RPM",
      },
      motion_type: "AGITATION",
      motion_mode: "NCIT:C70669",
    },
    EQUIPMENT: { value: [] },
  },
  EQUIPMENT: {
    EQUIPMENT: { value: ["NONE"] },
  },
};

const persistedConditionActivity = (metricName) => ({
  id: `reaction-2-condition-${metricName.toLowerCase()}`,
  value: `reaction-2-condition-${metricName.toLowerCase()}`,
  step_id: "reaction-2-step-1",
  activity_name: "CONDITION",
  position: 0,
  workup: {
    ...initialWorkupForMetric[metricName],
    automation_control: { status: "CAN_RUN" },
    automation_mode: reaction2Process.initial_conditions.automation_mode,
  },
  preconditions: reaction2Process.initial_conditions,
});

const openPersistedCondition = (metricName) => {
  const { container } = renderReaction2Steps({
    reactionProcess: {
      ...reaction2Process,
      reaction_process_steps: [
        reaction2Step("Charge reagents", 0, {
          activities: [persistedConditionActivity(metricName)],
        }),
      ],
    },
  });

  userEvent.click(
    container.querySelector(".activity .procedure-card--condition button[aria-label='pen']")
  );
};

const metricCases = {
  TEMPERATURE: {
    label: "Temperature",
    exercise: () => {
      const section = openMetricSubform("Temperature");

      setMetricValue("TEMPERATURE", 42);
      userEvent.selectOptions(screen.getByLabelText("additional_information"), "OIL_BATH");
      setSubform(section);

      return {
        TEMPERATURE: {
          value: 42,
          unit: "CELSIUS",
          additional_information: "OIL_BATH",
        },
        EQUIPMENT: { value: [] },
      };
    },
  },
  PH: {
    label: "pH",
    exercise: () => {
      const section = openMetricSubform("pH");

      setMetricValue("PH", 6.5);
      userEvent.selectOptions(screen.getByLabelText("additional_information"), "PH_ELECTRODE");
      setSubform(section);

      return {
        PH: {
          value: 6.5,
          unit: "PH",
          additional_information: "PH_ELECTRODE",
        },
        EQUIPMENT: { value: [] },
      };
    },
  },
  PRESSURE: {
    label: "Pressure",
    exercise: () => {
      const section = openMetricSubform("Pressure");

      setMetricValue("PRESSURE", 920);
      setSubform(section);

      return {
        PRESSURE: {
          value: 920,
          unit: "MBAR",
          additional_information: "",
        },
        EQUIPMENT: { value: [] },
      };
    },
  },
  IRRADIATION: {
    label: "Irradiation",
    exercise: () => {
      const section = openMetricSubform("Irradiation");

      setMetricValue("IRRADIATION", 365);
      setMetricValue("POWER_START", 55);
      userEvent.selectOptions(screen.getByLabelText("additional_information"), "LED");
      setSubform(section);

      return {
        IRRADIATION: {
          value: 365,
          unit: "NM",
          additional_information: "LED",
          power: {
            value: 55,
            unit: "WATT",
          },
        },
        EQUIPMENT: { value: [] },
      };
    },
  },
  MOTION: {
    label: "Motion",
    exercise: () => {
      const section = openMetricSubform("Motion");

      userEvent.selectOptions(screen.getByLabelText("motion_type"), "STIR_BAR");
      setMetricValue("MOTION", 600);
      setSubform(section);

      return {
        MOTION: {
          speed: {
            value: 600,
            unit: "RPM",
          },
          motion_type: "STIR_BAR",
          motion_mode: "NCIT:C70669",
        },
        EQUIPMENT: { value: [] },
      };
    },
  },
  EQUIPMENT: {
    label: "Equipment",
    exercise: () => {
      const section = openMetricSubform("Equipment");
      const equipment = selectFirstConditionEquipment("EQUIPMENT");

      setSubform(section);

      return {
        EQUIPMENT: { value: [equipment.value] },
      };
    },
  },
};

describe("reaction 2 New Condition metrics", () => {
  beforeEach(() => {
    resetReaction2Mocks();
  });

  test("covers every metric rendered by the condition form", () => {
    expect(Object.keys(metricCases)).toEqual(conditionFormMetricNames);
  });

  test.each(conditionFormMetricNames)("creates a condition activity with %s", async (metricName) => {
    openNewCondition();

    const expectedWorkup = metricCases[metricName].exercise();

    await saveCondition();

    expect(mockCreateActivity).toHaveBeenCalledWith(
      "reaction-2-step-1",
      expect.objectContaining({
        activity_name: "CONDITION",
        workup: expect.objectContaining(expectedWorkup),
      }),
      0
    );
  });

  test.each(conditionFormMetricNames)("edits and saves changed %s condition data", async (metricName) => {
    openPersistedCondition(metricName);

    const expectedWorkup = metricCases[metricName].exercise();
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockUpdateActivity).toHaveBeenCalledTimes(1));
    expect(mockUpdateActivity).toHaveBeenCalledWith(
      expect.objectContaining({
        id: `reaction-2-condition-${metricName.toLowerCase()}`,
        activity_name: "CONDITION",
        workup: expect.objectContaining(expectedWorkup),
      })
    );
  });
});
