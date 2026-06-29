import { cleanup, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import {
  fixtureVessel,
  mockCreateProcessStep,
  mockUpdateReactionProcessVessel,
  mockUpdateProcessStep,
  reaction2Process,
  reaction2ProcessWithSteps,
  renderReaction2Steps,
  renderReaction2VesselPreparations,
  resetReaction2Mocks,
} from "../../../testSupport/reaction2TestHelpers";

describe("reaction 2 step vessel assignment", () => {
  beforeEach(() => {
    resetReaction2Mocks();
  });

  test("assigns a vessel to step 1 while editing the step", () => {
    const reactionProcess = reaction2ProcessWithSteps(["Charge reagents"]);

    renderReaction2Steps({ reactionProcess, vessels: [fixtureVessel] });
    userEvent.click(screen.getByRole("button", { name: "pen" }));
    userEvent.click(screen.getByRole("button", { name: "VT-100 Round Bottom Flask" }));
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    expect(mockCreateProcessStep).not.toHaveBeenCalled();
    expect(mockUpdateProcessStep).toHaveBeenCalledTimes(1);
    expect(mockUpdateProcessStep).toHaveBeenCalledWith(
      expect.objectContaining({
        id: "reaction-2-step-1",
        reaction_process_vessel: expect.objectContaining({
          id: fixtureVessel.id,
          vesselable_type: fixtureVessel.vesselable_type,
        }),
      })
    );
  });

  test("assigns a vessel to step 1 and then sets its preparation in the left Vessel box", async () => {
    const reactionProcess = reaction2ProcessWithSteps(["Charge reagents"]);
    const preparation = reaction2Process.select_options.vessel_preparations.preparation_types[0];
    const cleanupType = reaction2Process.select_options.vessel_preparations.cleanup_types[0];

    renderReaction2Steps({ reactionProcess, vessels: [fixtureVessel] });
    userEvent.click(screen.getByRole("button", { name: "pen" }));
    userEvent.click(screen.getByRole("button", { name: "VT-100 Round Bottom Flask" }));
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    expect(mockUpdateProcessStep).toHaveBeenCalledWith(
      expect.objectContaining({
        id: "reaction-2-step-1",
        reaction_process_vessel: expect.objectContaining({
          id: fixtureVessel.id,
          vesselable_type: fixtureVessel.vesselable_type,
        }),
      })
    );

    cleanup();
    mockUpdateReactionProcessVessel.mockClear();

    const reactionProcessVessel = {
      id: "reaction-process-vessel-1",
      reaction_process_id: reactionProcess.id,
      vesselable_id: fixtureVessel.id,
      vesselable_type: fixtureVessel.vesselable_type,
      vesselable: fixtureVessel,
      step_names: ["Charge reagents"],
      preparations: [],
      cleanup: undefined,
    };

    const { container } = renderReaction2VesselPreparations({
      reactionProcess: {
        ...reactionProcess,
        reaction_process_vessels: [reactionProcessVessel],
      },
      vessels: [fixtureVessel],
    });

    userEvent.click(container.querySelector(".procedure-card--preparation button[aria-label='pen']"));
    userEvent.selectOptions(screen.getByLabelText("vesselable_preparations"), preparation.value);
    userEvent.selectOptions(screen.getByLabelText("vesselable_cleanup"), cleanupType.value);
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockUpdateReactionProcessVessel).toHaveBeenCalledTimes(1));
    expect(mockUpdateReactionProcessVessel).toHaveBeenCalledWith(
      expect.objectContaining({
        id: reactionProcessVessel.id,
        vesselable_id: fixtureVessel.id,
        vesselable_type: fixtureVessel.vesselable_type,
        preparations: [preparation.value],
        cleanup: cleanupType.value,
      })
    );
  });
});
