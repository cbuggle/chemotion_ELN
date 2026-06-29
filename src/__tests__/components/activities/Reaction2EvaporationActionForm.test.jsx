import {
  fillIfPresent,
  runActionFormSpecs,
} from "../../../testSupport/reaction2ActionFormSpecSupport";

runActionFormSpecs({
  activityName: "EVAPORATION",
  fillHappyPath: () => {
    fillIfPresent.select("origin_type", "FROM_REACTION");
  },
  expectedWorkup: () => ({
    origin_type: "FROM_REACTION",
  }),
});
