import {
  fillIfPresent,
  runActionFormSpecs,
  selectFixtureMolecularEntity,
  selectFixtureSampleIcon,
} from "../../../testSupport/reaction2ActionFormSpecSupport";

runActionFormSpecs({
  activityName: "ANALYSIS_CHROMATOGRAPHY",
  fillHappyPath: () => {
    selectFixtureSampleIcon();
    selectFixtureMolecularEntity(1);
    fillIfPresent.select("type", "CHMO:0001009");
    fillIfPresent.select("subtype", "CHMO:0001009");
    fillIfPresent.metric("INJECT_VOLUME", 12);
  },
});
