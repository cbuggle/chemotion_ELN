import {
  fillIfPresent,
  runActionFormSpecs,
} from "../../../testSupport/reaction2ActionFormSpecSupport";

runActionFormSpecs({
  activityName: "MIXING",
  fillHappyPath: () => {
    fillIfPresent.metric("SPEED", 650);
  },
  expectedWorkup: () => ({
    speed: expect.objectContaining({
      value: 650,
    }),
  }),
});
