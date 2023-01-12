#pragma once

#include <string>
#include <set>

struct VehiclePosition {
    double latitude;
    double longitude;
    double altitude;
    double heading;
};

using VehicleId = uint32_t;

class VehicleStatusProvider {
public:
    virtual ~VehicleStatusProvider() = default;
    virtual VehiclePosition getRecentPosition(VehicleId vehicleId) = 0;
    virtual bool isActive(VehicleId vehicleId) const = 0;
    virtual std::set<VehicleId> getVehiclesUpdatedRecently() const = 0;
};