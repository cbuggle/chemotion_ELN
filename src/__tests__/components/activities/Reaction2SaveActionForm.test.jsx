import {
  fillIfPresent,
  runActionFormSpecs,
  selectFixtureMolecularEntity,
} from "../../../testSupport/reaction2ActionFormSpecSupport";

runActionFormSpecs({
  activityName: "SAVE",
  fillHappyPath: () => {
    selectFixtureMolecularEntity();
    fillIfPresent.text("Name (Leave blank to autofill)", "Clean intermediate");
    fillIfPresent.text("Short Label (Leave blank to autofill)", "R2-Clean");
    fillIfPresent.metric("Target amount", 7.25);
    fillIfPresent.metric("PURITY", 0.96);
    fillIfPresent.text("Location", "Fixture shelf A");
    fillIfPresent.select("intermediate_type", "PURE");
  },
  expectedWorkup: () => ({
    name: "Clean intermediate",
    short_label: "R2-Clean",
    intermediate_type: "PURE",
  }),
});
