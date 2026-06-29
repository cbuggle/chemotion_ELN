import {
  fillIfPresent,
  runActionFormSpecs,
} from "../../../testSupport/reaction2ActionFormSpecSupport";

runActionFormSpecs({
  activityName: "CENTRIFUGATION",
  fillHappyPath: () => {
    fillIfPresent.metric("SPEED", 1200);
    fillIfPresent.metric("TEMPERATURE", 10);
  },
  expectedWorkup: () => ({
    SPEED: expect.objectContaining({
      value: 1200,
    }),
  }),
});
