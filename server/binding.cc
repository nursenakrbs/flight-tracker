#include <napi.h>
#include "VehicleController.h"
#include "VehiclClientStub.h"
#include <memory>

namespace {
  std::unique_ptr<VehicleStatusProvider> statusProvider;
  std::unique_ptr<VehicleNameProvider> nameProvider;
}

static Napi::Uint32Array getUpdatedVehicleIds(const Napi::CallbackInfo &info)
{
  Napi::Env env = info.Env();
  auto vehicles = statusProvider->getVehiclesUpdatedRecently();
  auto result = Napi::Uint32Array::New(env, vehicles.size());

  auto data = result.Data();
  for(const auto& id : vehicles) {
    *data = id;
    ++data;
  }
  return result;
}

static Napi::Value isActive(const Napi::CallbackInfo &info)
{
  Napi::Env env = info.Env();

  if (info.Length() < 1)
  {
    Napi::TypeError::New(env, "Wrong number of arguments")
        .ThrowAsJavaScriptException();
    return env.Null();
  }

  if (!info[0].IsNumber())
  {
    Napi::TypeError::New(env, "Wrong arguments").ThrowAsJavaScriptException();
    return env.Null();
  }

  auto id = info[0].As<Napi::Number>().Uint32Value();

  auto result = Napi::Boolean::New(env, statusProvider->isActive(id));
  return result;
}

static Napi::Value getName(const Napi::CallbackInfo &info)
{
  Napi::Env env = info.Env();

  if (info.Length() < 1)
  {
    Napi::TypeError::New(env, "Wrong number of arguments")
        .ThrowAsJavaScriptException();
    return env.Null();
  }

  if (!info[0].IsNumber())
  {
    Napi::TypeError::New(env, "Wrong arguments").ThrowAsJavaScriptException();
    return env.Null();
  }

  auto id = info[0].As<Napi::Number>().Uint32Value();

  auto result = Napi::String::New(env, nameProvider->getName(id));
  return result;
}

static Napi::Float32Array getPosition(const Napi::CallbackInfo &info)
{
  Napi::Env env = info.Env();

  if (info.Length() < 1)
  {
    Napi::TypeError::New(env, "Wrong number of arguments")
        .ThrowAsJavaScriptException();
    return {};
  }

  if (!info[0].IsNumber())
  {
    Napi::TypeError::New(env, "Wrong arguments").ThrowAsJavaScriptException();
    return {};
  }

  auto id = info[0].As<Napi::Number>().Uint32Value();
  auto result = Napi::Float32Array::New(env, 4);
  auto data = result.Data();
  auto position = statusProvider->getRecentPosition(id);

  data[0] = position.longitude;
  data[1] = position.latitude;
  data[2] = position.altitude;
  data[3] = position.heading;

  return result;
}

static Napi::Object Init(Napi::Env env, Napi::Object exports)
{
  auto controller = new VehicleController;
  statusProvider = std::unique_ptr<VehicleStatusProvider>(controller);
  nameProvider = std::unique_ptr<VehicleNameProvider>(new VehiclClientStub(std::bind(&VehicleController::handleMessage, controller, std::placeholders::_1)));

  exports.Set(Napi::String::New(env, "getUpdatedVehicleIds"),
              Napi::Function::New(env, getUpdatedVehicleIds));
  exports.Set(Napi::String::New(env, "isActive"),
              Napi::Function::New(env, isActive));
  exports.Set(Napi::String::New(env, "getPosition"),
              Napi::Function::New(env, getPosition));
  exports.Set(Napi::String::New(env, "getName"),
              Napi::Function::New(env, getName));
  return exports;
}

NODE_API_MODULE(addon, Init)
