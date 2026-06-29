import {
  fillIfPresent,
  runActionFormSpecs,
} from "../../../testSupport/reaction2ActionFormSpecSupport";

runActionFormSpecs({
  activityName: "CHROMATOGRAPHY",
  fillHappyPath: () => {
    fillIfPresent.select("type", "CHMO:0001009");
    fillIfPresent.select("subtype", "CHMO:0001009");
    fillIfPresent.metric("INJECT_VOLUME", 8);
    fillIfPresent.metric("LENGTH", 15);
  },
});
