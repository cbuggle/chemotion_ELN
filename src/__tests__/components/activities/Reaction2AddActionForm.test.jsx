import {
  fillIfPresent,
  runActionFormSpecs,
  selectFixtureMolecularEntity,
  selectFixtureSample,
} from "../../../testSupport/reaction2ActionFormSpecSupport";
import { reaction2Process } from "../../../testSupport/reaction2TestHelpers";

const sample = reaction2Process.select_options.materials.SAMPLE[0];

runActionFormSpecs({
  activityName: "ADD",
  fillHappyPath: () => {
    selectFixtureSample();
    selectFixtureMolecularEntity();
    fillIfPresent.metric("Target amount", 4.5);
    fillIfPresent.metric("TEMPERATURE", 31);
  },
  expectedWorkup: () => ({
    sample_id: sample.value,
    sample_name: sample.label,
  }),
});
