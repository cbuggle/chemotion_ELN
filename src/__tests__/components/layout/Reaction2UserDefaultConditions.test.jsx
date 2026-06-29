import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter } from "react-router-dom";

import {
  mockUpdateUserDefaultConditions,
  reaction2Process,
  resetReaction2Mocks,
} from "../../../testSupport/reaction2TestHelpers";
import UserMenu from "../../../components/layout/UserMenu";
import NotificationContext from "../../../contexts/NotificationContext";
import { SelectOptions } from "../../../contexts/SelectOptions";
import {
  SubFormController,
  SubFormToggle,
} from "../../../contexts/SubFormController";

const UserDefaultConditionsHarness = ({ defaultConditions }) => {
  localStorage.setItem("username", "fixture.user@example.test");

  return (
    <MemoryRouter>
      <NotificationContext.Provider value={{ addNotification: jest.fn() }}>
        <SelectOptions.Provider value={reaction2Process.select_options}>
          <SubFormController.Provider value={SubFormToggle()}>
            <UserMenu
              defaultConditions={defaultConditions}
              preconditions={reaction2Process.user_reaction_default_conditions}
            />
          </SubFormController.Provider>
        </SelectOptions.Provider>
      </NotificationContext.Provider>
    </MemoryRouter>
  );
};

const renderUserDefaultConditions = ({ defaultConditions }) => render(
  <UserDefaultConditionsHarness defaultConditions={defaultConditions} />
);

const openUserDefaultConditions = () => {
  userEvent.click(screen.getByText("fixture.user@example.test"));
  userEvent.click(screen.getByText("User Default Conditions"));
};

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

describe("reaction 2 user default conditions", () => {
  beforeEach(() => {
    resetReaction2Mocks();
    localStorage.clear();
  });

  test("sets a user default condition through the user menu", async () => {
    renderUserDefaultConditions({
      defaultConditions: {},
    });

    openUserDefaultConditions();
    const section = openConditionSubform("pH");
    setMetricValue("PH", 8.25);
    userEvent.selectOptions(screen.getByLabelText("additional_information"), "PH_ELECTRODE");
    userEvent.click(within(section).getByRole("button", { name: "Set" }));
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockUpdateUserDefaultConditions).toHaveBeenCalledTimes(1));
    expect(mockUpdateUserDefaultConditions).toHaveBeenCalledWith(
      expect.objectContaining({
        PH: {
          value: 8.25,
          unit: "PH",
          additional_information: "PH_ELECTRODE",
        },
        EQUIPMENT: { value: [] },
      })
    );
  });

  test("edits a user default condition through the user menu", async () => {
    renderUserDefaultConditions({
      defaultConditions: {
        TEMPERATURE: {
          value: 21,
          unit: "CELSIUS",
          additional_information: "AMBIENT",
        },
      },
    });

    openUserDefaultConditions();
    const section = openConditionSubform("Temperature");
    setMetricValue("TEMPERATURE", 44);
    userEvent.selectOptions(screen.getByLabelText("additional_information"), "OIL_BATH");
    userEvent.click(within(section).getByRole("button", { name: "Set" }));
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockUpdateUserDefaultConditions).toHaveBeenCalledTimes(1));
    expect(mockUpdateUserDefaultConditions).toHaveBeenCalledWith(
      expect.objectContaining({
        TEMPERATURE: {
          value: 44,
          unit: "CELSIUS",
          additional_information: "OIL_BATH",
        },
        EQUIPMENT: { value: [] },
      })
    );
  });
});
