# HU-TEST-000: Pruebas API Marvel Characters
# Se asume que la HU-TEST-000 es una historia de usuario que describe la necesidad de probar la API REST de personajes de Marvel.

Feature: Pruebas de la API REST de personajes de Marvel
  Como usuario de la API
  Quiero gestionar personajes de Marvel
  Para validar el correcto funcionamiento de los endpoints

  Background:
    * url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/elargo/api/characters'
  @id:1 @ObtenerPersonajes @solicitudExitosa200
  Scenario: Obtener todos los personajes (lista vacía o con datos)
    When method GET
    Then status 200
    And match response == '#[]'

  @id:2 @CrearPersonaje @solicitudExitosa201
  Scenario: Crear personaje exitosamente
    #Se asume que es el primer personaje que se crea en la base de datos
    # Este escenario crea un personaje y verifica que se haya creado correctamente
    Given request { name: 'Iron Man', alterego: 'Tony Stark', description: 'Genius billionaire', powers: ['Armor', 'Flight'] }
    When method POST
    Then status 201
    And match response.name == 'Iron Man'
    And match response.alterego == 'Tony Stark'
    And match response.description == 'Genius billionaire'
    And match response.powers contains 'Armor'
    And match response.powers contains 'Flight'
    * def createdId = response.id

  @id:3 @CrearPersonaje @errorValidacion400
  Scenario: Crear personaje con nombre duplicado
    # Este escenario verifica que no se puede crear un personaje con un nombre ya existente
    Given request { name: 'Iron Man', alterego: 'Otro', description: 'Otro', powers: ['Armor'] }
    When method POST
    Then status 400
    And match response.error == 'Character name already exists'

  @id:4 @CrearPersonaje @errorValidacion400
  Scenario: Crear personaje con campos requeridos vacíos
    # Este escenario verifica que los campos requeridos no pueden estar vacíos
    Given request { name: '', alterego: '', description: '', powers: [] }
    When method POST
    Then status 400
    And match response.name == 'Name is required'
    And match response.alterego == 'Alterego is required'
    And match response.description == 'Description is required'
    And match response.powers == 'Powers are required'

  @id:5 @ObtenerPersonajePorId @solicitudExitosa200
  Scenario: Obtener personaje por ID exitoso
    # Se asume que el ID del personaje creado en el escenario anterior es 1
    * def id = karate.get('createdId', 6)
    Given path id
    When method GET
    Then status 200
    And match response.id == id
    And match response.name == 'Iron Man'

  @id:6 @ObtenerPersonajePorId @errorNoEncontrado404
  Scenario: Obtener personaje por ID no existente
    Given path 999
    When method GET
    Then status 404
    And match response.error == 'Character not found'

  @id:7 @ActualizarPersonaje @solicitudExitosa200
  Scenario: Actualizar personaje exitosamente
    # Se asume que el ID del personaje creado en el escenario anterior es 1
    * def id = karate.get('createdId', 6)
    Given path id
    And request { name: 'Iron Man Actualizar', alterego: 'Tony Stark', description: 'Updated description', powers: ['Armor', 'Flight'] }
    When method PUT
    Then status 200
    And match response.description == 'Updated description'

  @id:8 @ActualizarPersonaje @errorNoEncontrado404
  Scenario: Actualizar personaje no existente
    # Se intenta actualizar un personaje que no existe
    Given path 999
    And request { name: 'Iron Man', alterego: 'Tony Stark', description: 'Updated description', powers: ['Armor', 'Flight'] }
    When method PUT
    Then status 404
    And match response.error == 'Character not found'

  @id:9 @EliminarPersonaje @solicitudExitosa204
  Scenario: Eliminar personaje exitosamente
    # Se asume que el ID del personaje creado en el escenario anterior es 1
    * def id = karate.get('createdId', 6)
    Given path id
    When method DELETE
    Then status 204

  @id:10 @EliminarPersonaje @errorNoEncontrado404
  Scenario: Eliminar personaje no existente
    # Se intenta eliminar un personaje que no existe
    Given path 999
    When method DELETE
    Then status 404
    And match response.error == 'Character not found'


  @id:11 @ErrorInternoServidor @errorInterno500
  Scenario: Error interno del servidor (simulación)
    # Este escenario simula un error interno del servidor (500)
    # Este escenario es solo de ejemplo, ya que la API no expone un caso real de 500
    Given path 'simulate-500'
    When method GET
    Then status 500
    # El mensaje de error puede variar según la implementación
