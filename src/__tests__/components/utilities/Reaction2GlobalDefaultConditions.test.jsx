import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import {
  mockUpdateUserDefaultConditions,
  reaction2Process,
  resetReaction2Mocks,
} from "../../../testSupport/reaction2TestHelpers";
import DefaultConditionsFormModal from "../../../components/utilities/DefaultConditionsFormModal";
import { SelectOptions } from "../../../contexts/SelectOptions";
import {
  SubFormController,
  SubFormToggle,
} from "../../../contexts/SubFormController";

const GlobalDefaultConditionsHarness = ({ defaultConditions }) => (
  <SelectOptions.Provider value={reaction2Process.select_options}>
    <SubFormController.Provider value={SubFormToggle()}>
      <DefaultConditionsFormModal
        defaultConditions={defaultConditions}
        preconditions={reaction2Process.user_reaction_default_conditions}
        scope="User"
        isOpen
        onToggleModal={jest.fn()}
      />
    </SubFormController.Provider>
  </SelectOptions.Provider>
);

const renderGlobalDefaultConditions = ({ defaultConditions }) => render(
  <GlobalDefaultConditionsHarness defaultConditions={defaultConditions} />
);

const openConditionSubform = (label) => {
  const section = screen.getByText(new RegExp(`^${label}\\b`)).closest(".form-section");

  userEvent.click(within(section).getByRole("button", { name: /^(Set|Change)$/ }));

  return section;
};

const setMetricValue = (metricName, value) => {
  const input = screen.getByLabelText(metricName);

  userEvent.clear(input);
  userEvent.type(input, String(value));
};

describe("reaction 2 global default conditions", () => {
  beforeEach(() => {
    resetReaction2Mocks();
  });

  test("sets a new global default temperature", async () => {
    const section = (() => {
      renderGlobalDefaultConditions({
        defaultConditions: {},
      });

      return openConditionSubform("Temperature");
    })();

    setMetricValue("TEMPERATURE", 37);
    userEvent.selectOptions(screen.getByLabelText("additional_information"), "WATER_BATH");
    userEvent.click(within(section).getByRole("button", { name: "Set" }));
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockUpdateUserDefaultConditions).toHaveBeenCalledTimes(1));
    expect(mockUpdateUserDefaultConditions).toHaveBeenCalledWith(
      expect.objectContaining({
        TEMPERATURE: {
          value: 37,
          unit: "CELSIUS",
          additional_information: "WATER_BATH",
        },
        EQUIPMENT: { value: [] },
      })
    );
  });

  test("edits an existing global default pressure", async () => {
    const section = (() => {
      renderGlobalDefaultConditions({
        defaultConditions: {
          PRESSURE: {
            value: 1013,
            unit: "MBAR",
            additional_information: "",
          },
          reaction_process_id: reaction2Process.id,
        },
      });

      return openConditionSubform("Pressure");
    })();

    setMetricValue("PRESSURE", 950);
    userEvent.click(within(section).getByRole("button", { name: "Set" }));
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockUpdateUserDefaultConditions).toHaveBeenCalledTimes(1));
    expect(mockUpdateUserDefaultConditions).toHaveBeenCalledWith(
      expect.objectContaining({
        reaction_process_id: reaction2Process.id,
        PRESSURE: {
          value: 950,
          unit: "MBAR",
          additional_information: "",
        },
        EQUIPMENT: { value: [] },
      })
    );
  });
});
