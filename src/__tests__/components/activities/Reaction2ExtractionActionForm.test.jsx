import { runActionFormSpecs } from "../../../testSupport/reaction2ActionFormSpecSupport";

runActionFormSpecs({
  activityName: "EXTRACTION",
  expectedWorkup: () => ({
    phase: "ORGANIC",
  }),
});
