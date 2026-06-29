import { runActionFormSpecs } from "../../../testSupport/reaction2ActionFormSpecSupport";

runActionFormSpecs({
  activityName: "FILTRATION",
  expectedWorkup: () => ({
    filtration_mode: "KEEP_PRECIPITATE",
  }),
});
