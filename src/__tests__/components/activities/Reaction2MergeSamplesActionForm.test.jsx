import userEvent from "@testing-library/user-event";
import { screen } from "@testing-library/react";

import {
  fillIfPresent,
  runActionFormSpecs,
} from "../../../testSupport/reaction2ActionFormSpecSupport";
import {
  fixtureVessel,
  reaction2Process,
} from "../../../testSupport/reaction2TestHelpers";

const [sample1, sample2] = reaction2Process.select_options.materials.SAMPLE;

runActionFormSpecs({
  activityName: "MERGE_SAMPLES",
  vessels: [fixtureVessel],
  fillHappyPath: () => {
    userEvent.click(screen.getByRole("button", { name: fixtureVessel.label }));
    fillIfPresent.select("sample_1_id", sample1.value);
    fillIfPresent.select("sample_2_id", sample2.value);
  },
  expectedWorkup: () => ({
    sample_1_id: sample1.value,
    sample_2_id: sample2.value,
  }),
  expectedActivity: () => ({
    reaction_process_vessel: expect.objectContaining({
      id: fixtureVessel.id,
      vesselable_type: fixtureVessel.vesselable_type,
    }),
  }),
});
