import {
  fillIfPresent,
  runActionFormSpecs,
  selectFixtureMolecularEntity,
  selectFixtureSampleIcon,
} from "../../../testSupport/reaction2ActionFormSpecSupport";

runActionFormSpecs({
  activityName: "ANALYSIS_ELEMENTAL",
  fillHappyPath: () => {
    selectFixtureSampleIcon();
    selectFixtureMolecularEntity(1);
    fillIfPresent.select("device", "CHMO:0001075");
  },
});
