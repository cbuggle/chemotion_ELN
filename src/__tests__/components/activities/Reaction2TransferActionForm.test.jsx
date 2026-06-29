import {
  expectInvalidTransferDoesNotSave,
  runActionFormSpecs,
  selectFixtureSample,
  targetTransferToSecondStep,
} from "../../../testSupport/reaction2ActionFormSpecSupport";
import { reaction2Process } from "../../../testSupport/reaction2TestHelpers";

const sample = reaction2Process.select_options.materials.SAMPLE[0];

runActionFormSpecs({
  activityName: "TRANSFER",
  fillHappyPath: () => {
    selectFixtureSample();
    targetTransferToSecondStep();
  },
  expectedWorkup: () => ({
    sample_id: sample.value,
    target_step_id: "reaction-2-step-2",
  }),
  assertErrorPath: expectInvalidTransferDoesNotSave,
});
