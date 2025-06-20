# HU-TEST-000: Pruebas API Marvel Characters
# Se asume que la HU-TEST-000 es una historia de usuario que describe la necesidad de probar la API REST de personajes de Marvel.

Feature: Pruebas de la API REST de personajes de Marvel
  Como usuario de la API
  Quiero gestionar personajes de Marvel
  Para validar el correcto funcionamiento de los endpoints

  Background:
    * url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/elargo/api/characters'

  Scenario: Obtener todos los personajes (lista vacía o con datos)
    When method GET
    Then status 200
    And match response == '#[]'

  Scenario: Crear personaje exitosamente
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

  Scenario: Crear personaje con nombre duplicado
    # Este escenario verifica que no se puede crear un personaje con un nombre ya existente
    Given request { name: 'Iron Man', alterego: 'Otro', description: 'Otro', powers: ['Armor'] }
    When method POST
    Then status 400
    And match response.error == 'Character name already exists'

  Scenario: Crear personaje con campos requeridos vacíos
    # Este escenario verifica que los campos requeridos no pueden estar vacíos
    Given request { name: '', alterego: '', description: '', powers: [] }
    When method POST
    Then status 400
    And match response.name == 'Name is required'
    And match response.alterego == 'Alterego is required'
    And match response.description == 'Description is required'
    And match response.powers == 'Powers are required'

  Scenario: Obtener personaje por ID exitoso
    # Se asume que el ID del personaje creado en el escenario anterior es 1
    * def id = karate.get('createdId', 1)
    Given path id
    When method GET
    Then status 200
    And match response.id == id
    And match response.name == 'Spider-Man'

  Scenario: Obtener personaje por ID no existente
    Given path 999
    When method GET
    Then status 404
    And match response.error == 'Character not found'

  Scenario: Actualizar personaje exitosamente
    # Se asume que el ID del personaje creado en el escenario anterior es 1
    * def id = karate.get('createdId', 1)
    Given path id
    And request { name: 'Iron Man Actualizar', alterego: 'Tony Stark', description: 'Updated description', powers: ['Armor', 'Flight'] }
    When method PUT
    Then status 200
    And match response.description == 'Updated description'

  Scenario: Actualizar personaje no existente
    # Se intenta actualizar un personaje que no existe
    Given path 999
    And request { name: 'Iron Man', alterego: 'Tony Stark', description: 'Updated description', powers: ['Armor', 'Flight'] }
    When method PUT
    Then status 404
    And match response.error == 'Character not found'

  Scenario: Eliminar personaje exitosamente
    # Se asume que el ID del personaje creado en el escenario anterior es 1
    * def id = karate.get('createdId', 1)
    Given path id
    When method DELETE
    Then status 204

  Scenario: Eliminar personaje no existente
    # Se intenta eliminar un personaje que no existe
    Given path 999
    When method DELETE
    Then status 404
    And match response.error == 'Character not found'

  Scenario: Error interno del servidor (simulación)
    # Este escenario simula un error interno del servidor (500)
    # Este escenario es solo de ejemplo, ya que la API no expone un caso real de 500
    Given path 'simulate-500'
    When method GET
    Then status 500
    # El mensaje de error puede variar según la implementación
