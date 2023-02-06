function clampedValue = clamp(value, minValue, maxValue)
    clampedValue = min(max(value, minValue), maxValue);
end