var advancedGamepadAssist = function () {
  return {
    templateUrl: '/ui/modules/apps/advancedGamepadAssist/app.html',
    replace: true,
    restrict: 'EA',
    link: function (scope, element, attrs) {
      scope.config = {
        speedSensitivity: 0.05,
        smoothingRate: 15,
        counterSteerStrength: 0.85
      };
      
      var lastUpdate = 0;
      scope.updateSettings = function() {
        var now = Date.now();
        if (now - lastUpdate > 50) {
          var luaCode = "if extensions.agaPhysics then extensions.agaPhysics.setConfig({speed_sensitivity=" + scope.config.speedSensitivity + ", countersteer=" + scope.config.counterSteerStrength + ", max_steer_speed=" + scope.config.smoothingRate + "}) end";
          bngApi.activeObjectLua(luaCode);
          lastUpdate = now;
        }
      };
    }
  };
};

angular.module('beamng.apps').directive('advancedGamepadAssist', [advancedGamepadAssist]);
