#pragma once

#include <string>

class VehicleNameProvider {
public:
    virtual ~VehicleNameProvider() = default;
    virtual std::string getName(uint32_t vehicleId) const = 0;
};