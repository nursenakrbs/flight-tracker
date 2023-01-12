#pragma once

#include <functional>

struct VehicleMessage {
    int id;
    double x;
    double y;
    double z;
};

using VehicleMessageHandler = std::function<void(const VehicleMessage&)>;