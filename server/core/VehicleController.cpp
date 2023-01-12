#include "VehicleController.h"
#include <exception>
#include <cmath>

VehicleController::VehicleController() {
}

VehiclePosition VehicleController::getRecentPosition(VehicleId vehicleId) {
    const std::lock_guard<std::mutex> lock(mDataMutex);
    auto found = mPositions.find(vehicleId);
    if(found == mPositions.end())
        throw std::logic_error("invalid id");
    auto position = found->second;
    mVehiclesUpdatedRecently.erase(vehicleId);
    return position;
}

bool VehicleController::isActive(VehicleId vehicleId) const {
    const std::lock_guard<std::mutex> lock(mDataMutex);
    return mPositions.find(vehicleId) != mPositions.end();
}

std::set<VehicleId> VehicleController::getVehiclesUpdatedRecently() const {
    const std::lock_guard<std::mutex> lock(mDataMutex);
    return mVehiclesUpdatedRecently;
}

void VehicleController::handleMessage(const VehicleMessage& message) {
    const std::lock_guard<std::mutex> lock(mDataMutex);
    VehiclePosition position;
    position.longitude = message.x;
    position.latitude = message.y;
    position.altitude = message.z;
    auto prevPos = mPositions.find(message.id);
    if(prevPos != mPositions.end()) {
        position.heading = -std::atan((position.longitude - prevPos->second.longitude)/(position.latitude - prevPos->second.latitude));
    }
    else
        position.heading = 0;

    mPositions[message.id] = position;
    mVehiclesUpdatedRecently.emplace(message.id);
}
