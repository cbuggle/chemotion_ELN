import TimeDecorator from "../../decorators/TimeDecorator";
import { timeMeasurements } from "../../constants/timeMeasurements";

describe("TimeDecorator", () => {
  test("splits duration into hour-based parts", () => {
    expect(
      TimeDecorator.hourBasedTimespan(
        timeMeasurements.msInHour +
        2 * timeMeasurements.msInMinute +
        3 * timeMeasurements.msInSecond +
        4
      )
    ).toEqual({
      hours: 1,
      minutes: 2,
      seconds: 3,
      milliSeconds: 4
    });
  });

  test("calculates duration from time parts", () => {
    expect(TimeDecorator.calculateDuration({ hours: 1, minutes: 2, seconds: 3 })).toBe(
      timeMeasurements.msInHour +
      2 * timeMeasurements.msInMinute +
      3 * timeMeasurements.msInSecond
    );
  });

  test("formats duration strings compactly", () => {
    expect(TimeDecorator.timeString(3 * timeMeasurements.msInSecond)).toBe("3s");
    expect(TimeDecorator.timeString(2 * timeMeasurements.msInMinute + 3 * timeMeasurements.msInSecond)).toBe("2min 3s");
    expect(TimeDecorator.timeString(timeMeasurements.msInHour + 2 * timeMeasurements.msInMinute + 3 * timeMeasurements.msInSecond)).toBe("1h 2min 3s");
  });

  test("formats daytime with leading zeros", () => {
    expect(TimeDecorator.daytime("2026-06-23T01:02:03")).toBe("01:02:03");
  });

  test("returns timing summaries only when a duration is present", () => {
    expect(TimeDecorator.summary(0)).toBeUndefined();
    expect(TimeDecorator.summary(3000)).toBe("3s");
    expect(
      TimeDecorator.summary(
        3000,
        "2026-06-23T01:02:03",
        "2026-06-23T01:02:06"
      )
    ).toBe("3s (01:02:03\u00a0\u2013\u00a001:02:06)");
  });
});
