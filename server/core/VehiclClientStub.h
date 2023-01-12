#pragma once

#include "VehicleNameProvider.h"
#include "VehicleMessage.h"
#include <thread>
#include <vector>
#include <memory>

struct VehicleStubContext;

class VehiclClientStub : public VehicleNameProvider {
public:
    VehiclClientStub(const VehicleMessageHandler& handler);
    std::string getName(uint32_t vehicleId) const override;

private:
    void sendMessages();

    std::thread mMessagingThread;
    VehicleMessageHandler mMessageHandler;
    std::vector<std::unique_ptr<VehicleStubContext>> mVehicles;
};