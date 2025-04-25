import * as Burnt from "burnt";
import { type ToastOptions } from "burnt/build/types";
import { useEffect, useState } from "react";

export function useDebounce<T>(value: T, delay?: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value);
    }, delay ?? 500);

    return () => {
      clearTimeout(timer);
    };
  }, [value, delay]);

  return debouncedValue;
}

export function useToast() {
  const defaultSuccess = {
    title: "Success!",
    message: "", // optional
    haptic: "success", // or "success", "warning", "error"
    duration: 2, // duration in seconds
    shouldDismissByDrag: true,
    from: "top", // "top" or "bottom"
    // optionally customize layout
    layout: {
      iconSize: {
        height: 24,
        width: 24,
      },
    },
    icon: {
      ios: {
        name: "checkmark.seal",
        color: "#87D96C",
      },
    },
  };
  const defaultError = {
    ...defaultSuccess,
    title: "Error!",
    haptic: "error",
    icon: { ios: { name: "xmark.seal", color: "#FF453A" } },
  };
  const toastSuccess = (options: ToastOptions) => {
    Burnt.toast({ ...defaultSuccess, ...options } as ToastOptions);
  };
  const toastError = (options: ToastOptions) => {
    Burnt.toast({ ...defaultError, ...options } as ToastOptions);
  };

  return { toastSuccess, toastError };
}
