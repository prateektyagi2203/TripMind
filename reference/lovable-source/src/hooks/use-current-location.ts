import { useEffect, useState } from "react";

export interface CurrentLocation {
  city?: string;
  region?: string;
  country?: string;
  countryCode?: string;
  latitude: number;
  longitude: number;
}

export type LocationStatus =
  | "idle"
  | "prompting"
  | "loading"
  | "granted"
  | "denied"
  | "unavailable"
  | "error";

interface State {
  status: LocationStatus;
  location?: CurrentLocation;
  error?: string;
}

/**
 * Asks the browser for geolocation and reverse-geocodes it to a city via the
 * free BigDataCloud client endpoint (no API key). Designed to be swapped for
 * a server-side Google Maps reverse-geocode later without changing callers.
 */
export function useCurrentLocation(autoRequest = true) {
  const [state, setState] = useState<State>({ status: "idle" });


  useEffect(() => {
    if (!autoRequest) return;
    if (typeof navigator === "undefined" || !navigator.geolocation) {
      setState({ status: "unavailable" });
      return;
    }
    setState((s) => (s.status === "idle" ? { status: "prompting" } : s));

    let cancelled = false;
    const handlePos = async (pos: GeolocationPosition) => {
      if (cancelled) return;
      const { latitude, longitude } = pos.coords;
      setState((prev) => ({
        status: prev.status === "granted" ? "granted" : "loading",
        location: { ...prev.location, latitude, longitude },
      }));
      try {
        const res = await fetch(
          `https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${latitude}&longitude=${longitude}&localityLanguage=en`,
        );
        const data = await res.json();
        if (cancelled) return;
        setState({
          status: "granted",
          location: {
            latitude,
            longitude,
            city: data.city || data.locality || data.principalSubdivision,
            region: data.principalSubdivision,
            country: data.countryName,
            countryCode: data.countryCode,
          },
        });
      } catch (e) {
        if (cancelled) return;
        setState({
          status: "granted",
          location: { latitude, longitude },
          error: e instanceof Error ? e.message : "reverse geocode failed",
        });
      }
    };

    const handleErr = (err: GeolocationPositionError) => {
      if (cancelled) return;
      setState({
        status: err.code === err.PERMISSION_DENIED ? "denied" : "error",
        error: err.message,
      });
    };

    const opts: PositionOptions = {
      enableHighAccuracy: false,
      timeout: 10000,
      maximumAge: 60 * 1000,
    };
    navigator.geolocation.getCurrentPosition(handlePos, handleErr, opts);
    const watchId = navigator.geolocation.watchPosition(handlePos, handleErr, opts);

    return () => {
      cancelled = true;
      navigator.geolocation.clearWatch(watchId);
    };
  }, [autoRequest]);

  return state;
}
