#include "VehiclClientStub.h"
#include <array>
#include <cmath>
#include <chrono>

using Position2D = std::array<double,2>;

const double StepSize = 0.01;

class Pattern {
public:
    virtual ~Pattern() {}
    virtual Position2D getNextPosition() = 0;
};

struct VehicleStubContext {
    std::string name;
    VehicleMessage message;
    std::unique_ptr<Pattern> pattern;
    void updateMessage() {
        auto pos = pattern->getNextPosition();
        message.x = pos[0];
        message.y = pos[1];
    }
};

class LinePattern : public Pattern {
public:
    LinePattern(Position2D origin, double orient) : 
        mLastPosition(origin), mHorizontalStep(StepSize * std::cos(orient)), mVerticalStep(StepSize * std::sin(orient))  {}
    Position2D getNextPosition() override {
        mLastPosition[0] += mHorizontalStep;
        mLastPosition[1] += mVerticalStep;
        return mLastPosition;
    }
private:
    Position2D mLastPosition;
    const double mHorizontalStep;
    const double mVerticalStep;
    
};

class SinePattern : public Pattern {
public:
    SinePattern(Position2D origin) : mLastPosition(origin) {}
    Position2D getNextPosition() override {
        mLastPosition[0] += StepSize;
        mLastPosition[1] += StepSize * std::sin(mAngle);
        mAngle += 0.05;
        return mLastPosition;
    }
private:
    Position2D mLastPosition;
    double mAngle = 0;
};
 
VehiclClientStub::VehiclClientStub(const VehicleMessageHandler& handler) : mMessageHandler(handler) {
    mMessagingThread = std::thread(&VehiclClientStub::sendMessages, this);

    auto vehicle1 = new VehicleStubContext();
    vehicle1->message.id = 1;
    vehicle1->message.z = 200;
    vehicle1->name = "Aslan";
    vehicle1->pattern = std::unique_ptr<LinePattern>(new LinePattern({32.56, 39.74}, 0.6));
    auto vehicle2 = new VehicleStubContext();
    vehicle2->message.id = 2;
    vehicle2->message.z = 500;
    vehicle2->name = "Kaplan";
    vehicle2->pattern = std::unique_ptr<SinePattern>(new SinePattern({33.57, 40.33}));

    mVehicles.push_back(std::unique_ptr<VehicleStubContext>(vehicle1));
    mVehicles.push_back(std::unique_ptr<VehicleStubContext>(vehicle2));
}

std::string VehiclClientStub::getName(uint32_t vehicleId) const {
    for(const auto& v : mVehicles) {
        if(v->message.id == vehicleId)
            return v->name;
    }
    return "";
}


void VehiclClientStub::sendMessages() {
    while(true) {
        for(const auto& v : mVehicles) {
            v->updateMessage();
            mMessageHandler(v->message);
        }
        
        std::this_thread::sleep_for(std::chrono::milliseconds(600));
    }
}