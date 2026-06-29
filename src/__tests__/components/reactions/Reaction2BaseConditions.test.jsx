import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import {
  mockUpdateReactionDefaultConditions,
  reaction2Process,
  resetReaction2Mocks,
} from "../../../testSupport/reaction2TestHelpers";
import ReactionConditionsFormButton from "../../../components/reactions/navbar/ReactionConditionsFormButton";
import { SelectOptions } from "../../../contexts/SelectOptions";
import {
  SubFormController,
  SubFormToggle,
} from "../../../contexts/SubFormController";

const ReactionBaseConditionsHarness = ({ defaultConditions }) => (
  <SelectOptions.Provider value={reaction2Process.select_options}>
    <SubFormController.Provider value={SubFormToggle()}>
      <ReactionConditionsFormButton
        defaultConditions={defaultConditions}
        preconditions={reaction2Process.user_reaction_default_conditions}
      />
    </SubFormController.Provider>
  </SelectOptions.Provider>
);

const renderReactionBaseConditions = ({ defaultConditions }) => render(
  <ReactionBaseConditionsHarness defaultConditions={defaultConditions} />
);

const openReactionBaseConditions = () => {
  userEvent.click(screen.getByRole("button", { name: "temperature-high" }));
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

describe("reaction 2 base conditions", () => {
  beforeEach(() => {
    resetReaction2Mocks();
  });

  test("sets a new reaction base temperature", async () => {
    renderReactionBaseConditions({
      defaultConditions: {
        reaction_process_id: reaction2Process.id,
      },
    });

    openReactionBaseConditions();
    const section = openConditionSubform("Temperature");
    setMetricValue("TEMPERATURE", 39);
    userEvent.selectOptions(screen.getByLabelText("additional_information"), "OIL_BATH");
    userEvent.click(within(section).getByRole("button", { name: "Set" }));
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockUpdateReactionDefaultConditions).toHaveBeenCalledTimes(1));
    expect(mockUpdateReactionDefaultConditions).toHaveBeenCalledWith(
      expect.objectContaining({
        reaction_process_id: reaction2Process.id,
        TEMPERATURE: {
          value: 39,
          unit: "CELSIUS",
          additional_information: "OIL_BATH",
        },
        EQUIPMENT: { value: [] },
      })
    );
  });

  test("edits an existing reaction base pH", async () => {
    renderReactionBaseConditions({
      defaultConditions: {
        reaction_process_id: reaction2Process.id,
        PH: {
          value: 7,
          unit: "PH",
          additional_information: "PH_STRIPE",
        },
      },
    });

    openReactionBaseConditions();
    const section = openConditionSubform("pH");
    setMetricValue("PH", 5.75);
    userEvent.selectOptions(screen.getByLabelText("additional_information"), "PH_ELECTRODE");
    userEvent.click(within(section).getByRole("button", { name: "Set" }));
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockUpdateReactionDefaultConditions).toHaveBeenCalledTimes(1));
    expect(mockUpdateReactionDefaultConditions).toHaveBeenCalledWith(
      expect.objectContaining({
        reaction_process_id: reaction2Process.id,
        PH: {
          value: 5.75,
          unit: "PH",
          additional_information: "PH_ELECTRODE",
        },
        EQUIPMENT: { value: [] },
      })
    );
  });
});
