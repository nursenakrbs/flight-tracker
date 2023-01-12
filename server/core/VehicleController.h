#pragma once

#include "VehicleStatusProvider.h"
#include "VehicleMessage.h"
#include <map>
#include <mutex>

class VehicleController : public VehicleStatusProvider {
public:
    VehicleController();
    VehiclePosition getRecentPosition(VehicleId vehicleId) override;
    bool isActive(VehicleId vehicleId) const override; 
    std::set<VehicleId> getVehiclesUpdatedRecently() const override;

    void handleMessage(const VehicleMessage& message);

private:
    std::map<VehicleId, std::string> mNames;
    std::map<VehicleId, VehiclePosition> mPositions;
    std::set<VehicleId> mVehiclesUpdatedRecently;
    mutable std::mutex mDataMutex;
};