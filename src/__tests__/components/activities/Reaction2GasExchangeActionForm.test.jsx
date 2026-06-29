import {
  fillIfPresent,
  runActionFormSpecs,
} from "../../../testSupport/reaction2ActionFormSpecSupport";

runActionFormSpecs({
  activityName: "GAS_EXCHANGE",
  fillHappyPath: () => {
    fillIfPresent.select("solvents", "CHEBI:17997");
  },
});
