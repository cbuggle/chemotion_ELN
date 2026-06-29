import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import {
  mockCreateActivity,
  reaction2Process,
  reaction2Step,
  resetReaction2Mocks,
} from "../../../testSupport/reaction2TestHelpers";
import CreateTransferZone from "../../../components/preparations/CreateTransferZone";
import NotificationContext from "../../../contexts/NotificationContext";
import { SelectOptions } from "../../../contexts/SelectOptions";

const initialSample = reaction2Process.select_options.materials.SAMPLE[0];
const targetStep = reaction2Step("Receive initial sample", 0, {
  id: "reaction-2-initial-sample-target",
  value: "reaction-2-initial-sample-target",
  label: "1/1 Receive initial sample",
});

const sampleProcessSelectOptions = {
  ...reaction2Process.select_options,
  FORMS: {
    ...reaction2Process.select_options.FORMS,
    TRANSFER: {
      ...reaction2Process.select_options.FORMS.TRANSFER,
      transferable_samples: [initialSample],
      targets: [
        {
          id: targetStep.id,
          value: targetStep.id,
          label: targetStep.label,
          automation_mode: targetStep.automation_mode,
          saved_sample_ids: [],
        },
      ],
    },
  },
};

const renderInitialSampleTransferZone = () => render(
  <NotificationContext.Provider value={{ addNotification: jest.fn() }}>
    <SelectOptions.Provider value={sampleProcessSelectOptions}>
      <CreateTransferZone
        sample={{
          id: initialSample.value,
          short_label: initialSample.label,
          external_label: initialSample.label,
          name: "Initial sample",
          target_amount: initialSample.amount,
          amounts: initialSample.unit_amounts,
          sample_svg_file: initialSample.sample_svg_file,
        }}
      />
    </SelectOptions.Provider>
  </NotificationContext.Provider>
);

describe("reaction 2 sample process initial sample transfer", () => {
  beforeEach(() => {
    resetReaction2Mocks();
  });

  test("creates a transfer from the initial sample to a reaction step", async () => {
    renderInitialSampleTransferZone();

    userEvent.click(screen.getByRole("button", { name: "+ Transfer" }));

    expect(screen.getByLabelText("sample_id")).toHaveValue(String(initialSample.value));
    expect(screen.getByLabelText("source_step_id")).toHaveValue("");

    userEvent.selectOptions(screen.getByLabelText("target_step_id"), targetStep.id);
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockCreateActivity).toHaveBeenCalledTimes(1));
    expect(mockCreateActivity).toHaveBeenCalledWith(
      targetStep.id,
      expect.objectContaining({
        activity_name: "TRANSFER",
        workup: expect.objectContaining({
          sample_id: initialSample.value,
          target_step_id: targetStep.id,
          automation_mode: reaction2Process.initial_conditions.automation_mode,
        }),
      })
    );
  });
});
