import {
  fillIfPresent,
  runActionFormSpecs,
} from "../../../testSupport/reaction2ActionFormSpecSupport";

runActionFormSpecs({
  activityName: "CRYSTALLIZATION",
  fillHappyPath: () => {
    fillIfPresent.metric("VOLUME", 5);
    fillIfPresent.metric("TEMPERATURE", 4);
  },
  expectedWorkup: () => ({
    amount: expect.objectContaining({
      value: 5,
    }),
    crystallization_mode: expect.any(String),
  }),
});
