#include <iostream>
#include <VehicleController.h>
#include <VehiclClientStub.h>

int main(int argc, char** argv)
{
    VehicleController controller;
    auto client = new VehiclClientStub(std::bind(&VehicleController::handleMessage, &controller, std::placeholders::_1));

    std::string cmd;
    while(true) {
        std::cin >> cmd;
        if(cmd == "x")
            std::exit(0);
        if(cmd == "p") {
            auto vehicles = controller.getVehiclesUpdatedRecently();
            for(const auto& v : vehicles)
                std::cout << "id: " << v << std::endl;
        }
    }

    return 0;
}