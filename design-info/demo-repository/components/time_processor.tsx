import { useEffect, useState } from "react";

/**
 * Converts a Date object to a string representation.
 * @param {Object} props - The input properties.
 * @param {Date} props.date - The date to be converted.
 * @param {string} props.separator - The separator to be used in the string representation.
 * @returns {string} The string representation of the date.
 */
export const dateToString = (props: { date: Date; separator: string }) => {
  if (props.separator === "/") {
    return props.date.toLocaleDateString("en-GB", {
      year: "numeric",
      month: "numeric",
      day: "numeric",
    });
  } else if (props.separator === "-") {
    const year = props.date.getFullYear();
    const month = String(props.date.getMonth() + 1).padStart(2, "0"); // 月份从0开始，需要加1
    const day = String(props.date.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
  }
};

export function addDaysToDate(startDate: Date, daysToAdd: number) {
  const newDate = new Date(startDate);
  newDate.setDate(newDate.getDate() + daysToAdd);
  return newDate;
}

// const startDate = new Date(2024,0,28)
// console.log(dateToString(startDate))
// console.log(dateToString(addDaysToDate(startDate,7)))

export const calculateTimeLeft = (targetTimestamp: number) => {
  const diff = targetTimestamp - Date.now();
  const timeLeft = { hours: 0, minutes: 0, seconds: 0 };
  // console.log("targetTimestamp", targetTimestamp);
  // console.log("Date.now()", Date.now());
  if (diff <= 0) {
    return { hours: 0, minutes: 0, seconds: 0 };
  }

  timeLeft.hours = Math.floor(diff / (1000 * 60 * 60));
  timeLeft.minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
  timeLeft.seconds = Math.floor((diff % (1000 * 60)) / 1000);
  return timeLeft;
};

export const useCountdown = (targetTimestamp: number) => {
  const [timeLeft, setTimeLeft] = useState(calculateTimeLeft(targetTimestamp));

  useEffect(() => {
    const timer = setInterval(() => {
      const timeLeft = calculateTimeLeft(targetTimestamp);
      setTimeLeft(timeLeft);

      if (
        timeLeft.hours === 0 &&
        timeLeft.minutes === 0 &&
        timeLeft.seconds === 0
      ) {
        clearInterval(timer);
      }
    }, 1000);

    return () => clearInterval(timer);
  }, [targetTimestamp]);

  return timeLeft;
};

export const dateToTimeStamp = (timeString: string): number => {
  return new Date(timeString).getTime();
};
