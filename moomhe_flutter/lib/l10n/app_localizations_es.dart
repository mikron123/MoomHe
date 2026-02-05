// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Experto AI';

  @override
  String get appName => 'Experto';

  @override
  String get guest => 'Invitado';

  @override
  String get loginToSaveDesigns => 'Inicia sesión para guardar tus diseños';

  @override
  String get loggedOutSuccess => 'Sesión cerrada exitosamente';

  @override
  String get uploadImage => 'Subir Imagen';

  @override
  String get clickToUploadImage =>
      'Haz clic aquí para subir una imagen de la galería';

  @override
  String get gallery => 'Galería';

  @override
  String get camera => 'Cámara';

  @override
  String get uploadItem => 'Añadir Objeto';

  @override
  String get redesign => 'Rediseñar';

  @override
  String get more => 'Más';

  @override
  String get moreOptions => 'Más Opciones';

  @override
  String get history => 'Historial';

  @override
  String get noHistoryYet => 'Aún no hay historial';

  @override
  String get uploadedImagesWillAppear =>
      'Las imágenes que subas y edites aparecerán aquí';

  @override
  String get whatToChange => '¿Qué cambiar?';

  @override
  String get uploadImageFirst => 'Por favor sube una imagen primero';

  @override
  String get uploadingImage => 'Subiendo imagen...';

  @override
  String get errorUploadingImage => 'Error al subir imagen';

  @override
  String get itemImageLoaded =>
      '¡Imagen del objeto cargada! Describe en el prompt dónde añadirlo.';

  @override
  String get addAttachedItem => 'Añadir el objeto adjunto a la imagen';

  @override
  String get processingStarting => 'Iniciando...';

  @override
  String get processingMagic => 'La magia está sucediendo';

  @override
  String get processing => 'Procesando...';

  @override
  String get connectingToCloud => 'Conectando a la nube... ☁️';

  @override
  String get sendingToAI => 'Enviando a la IA... 🤖';

  @override
  String get analyzingItem => 'Analizando objeto... 🔍';

  @override
  String get creatingDesign => 'Creando diseño... ✨';

  @override
  String get funPhrase1 => 'Enviando la imagen a otra dimensión... 🌀';

  @override
  String get funPhrase2 => 'Enseñando a la IA a apreciar el buen diseño... 🎨';

  @override
  String get funPhrase3 => 'Convenciendo a los píxeles de cooperar... 🤝';

  @override
  String get funPhrase4 => 'Un poco de magia digital en camino... ✨';

  @override
  String get funPhrase5 => 'Preguntando a la IA qué piensa... 🤔';

  @override
  String get funPhrase6 => 'Mezclando colores como un artista real... 🖌️';

  @override
  String get funPhrase7 => 'Calculando el ángulo perfecto... 📐';

  @override
  String get funPhrase8 => 'Añadiendo estilo a tu vida... 💫';

  @override
  String get funPhrase9 => 'Haciendo que la habitación se vea más cara... 💎';

  @override
  String get funPhrase10 => 'Activando la magia del diseño... 🪄';

  @override
  String get funPhrase11 =>
      'Consultando con los diseñadores de interiores digitales... 🏠';

  @override
  String get funPhrase12 =>
      'Intentando no emocionarme demasiado con el resultado... 😍';

  @override
  String get funPhrase13 => 'Verás algo increíble en un momento... 🚀';

  @override
  String get funPhrase14 =>
      'Asegurándome de que todo sea perfecto para ti... 👌';

  @override
  String get designStyle => 'Estilo de Diseño';

  @override
  String get wallColor => 'Cambiar Color';

  @override
  String get lighting => 'Iluminación';

  @override
  String get furniture => 'Muebles';

  @override
  String get doorsWindows => 'Puertas y Ventanas';

  @override
  String get bathroom => 'Baño';

  @override
  String get repairs => 'Reparaciones';

  @override
  String get general => 'General';

  @override
  String get selectDesignStyle => 'Selecciona Estilo de Diseño';

  @override
  String get colorPalette => 'Paleta de Colores';

  @override
  String get selectLightingType => 'Selecciona Tipo de Iluminación';

  @override
  String get selectFurnitureType => 'Selecciona Tipo de Mueble';

  @override
  String get selectRepairType => 'Selecciona Tipo de Reparación/Daño';

  @override
  String get bathroomOptions => 'Opciones de Baño';

  @override
  String changeStyleTo(String styleName) {
    return 'Cambiar el estilo a $styleName';
  }

  @override
  String get whatToDo => '¿Qué hacer?';

  @override
  String get describeChange => 'Describe el cambio deseado...';

  @override
  String get cancel => 'Cancelar';

  @override
  String get execute => 'Ejecutar';

  @override
  String comingSoon(String feature) {
    return '$feature - ¡Próximamente!';
  }

  @override
  String get colorChange => 'Cambiar Color';

  @override
  String get allWalls => 'Todas las Paredes';

  @override
  String get paintAllWalls => 'Pintar todas las paredes de la habitación';

  @override
  String get specificObject => 'Objeto Específico';

  @override
  String get selectWhatToPaint => 'Elige qué quieres pintar';

  @override
  String get exampleObjects => 'Por ejemplo: sofá, techo, armario...';

  @override
  String get confirm => 'Confirmar';

  @override
  String get windowOptions => 'Opciones de Ventanas';

  @override
  String get doorOptions => 'Opciones de Puertas';

  @override
  String get toiletOptions => 'Opciones de Inodoro';

  @override
  String get bathtubOptions => 'Opciones de Bañera';

  @override
  String get showerOptions => 'Opciones de Ducha';

  @override
  String get sinkOptions => 'Opciones de Lavabo';

  @override
  String get jacuzziOptions => 'Opciones de Jacuzzi/Spa';

  @override
  String get poolOptions => 'Opciones de Piscina';

  @override
  String get professionalSubscription => 'Plan Profesional';

  @override
  String get specialLaunchPrices => 'Precios especiales de lanzamiento 🚀';

  @override
  String get purchaseFailed => 'Compra fallida';

  @override
  String get yourCurrentPlan => 'Tu plan actual';

  @override
  String get selectPlan => 'Seleccionar Plan';

  @override
  String get perMonth => '/mes';

  @override
  String get starterPlan => 'Inicial';

  @override
  String get valuePlan => 'Valor';

  @override
  String get proPlan => 'Profesional';

  @override
  String imagesPerMonth(int count) {
    return '$count imágenes por mes';
  }

  @override
  String get whatsappSupport => 'Soporte por WhatsApp';

  @override
  String get historyStorage => 'Almacenamiento de Historial';

  @override
  String get vipWhatsappSupport => 'Soporte VIP por WhatsApp';

  @override
  String get processingPriority => 'Prioridad de Procesamiento';

  @override
  String get bestValue => 'Mejor valor: ¡4x más imágenes! 🔥';

  @override
  String get forProfessionals => 'Para profesionales ⭐';

  @override
  String savePerImage(String percent) {
    return 'Ahorra $percent% por imagen';
  }

  @override
  String get allDesignTools => 'Todas las herramientas de diseño';

  @override
  String get fastSupport => 'Soporte rápido';

  @override
  String get noAds => 'Sin anuncios';

  @override
  String get restorePurchases => 'Restaurar Compras';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get createNewAccount => 'Nueva Cuenta';

  @override
  String get welcomeBack =>
      '¡Bienvenido de nuevo! Inicia sesión para continuar';

  @override
  String get joinUs =>
      'Únete para guardar diseños y acceder a todas las funciones';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get fillAllFields => 'Por favor completa todos los campos';

  @override
  String get passwordsNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get loginButton => 'Iniciar Sesión';

  @override
  String get createAccountButton => 'Crear Cuenta';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get enterEmailFirst =>
      'Por favor ingresa una dirección de correo primero';

  @override
  String get passwordResetEmailSent =>
      'Password reset email sent! Check your inbox and spam folder.';

  @override
  String get passwordResetError => 'Error sending password reset email';

  @override
  String get termsAgreement => 'Al iniciar sesión aceptas los';

  @override
  String get termsOfService => 'Términos de Servicio';

  @override
  String get and => 'y';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get privacyPolicyUrl => 'https://moomhe.com/privacy-en.html';

  @override
  String get termsOfServiceUrl => 'https://moomhe.com/eula-en.html';

  @override
  String get loggingIn => 'Iniciando sesión...';

  @override
  String get creatingAccount => 'Creando cuenta...';

  @override
  String get loginSuccess => '¡Sesión iniciada exitosamente! 🎉';

  @override
  String get accountCreated => '¡Cuenta creada exitosamente! 🎉';

  @override
  String get loginError => 'Error de inicio de sesión';

  @override
  String get userNotFound => 'Usuario no encontrado';

  @override
  String get wrongPassword => 'Contraseña incorrecta';

  @override
  String get emailInUse => 'El correo ya está en uso';

  @override
  String get weakPassword => 'La contraseña es muy débil';

  @override
  String get invalidEmail => 'Dirección de correo inválida';

  @override
  String get exitAccount => 'Salir de la cuenta';

  @override
  String get loginWithEmail =>
      'Inicia sesión con correo para guardar tus diseños';

  @override
  String get mySubscription => 'Mi Suscripción';

  @override
  String creditsRemaining(int count) {
    return '$count créditos restantes';
  }

  @override
  String get upgradeToPremium => 'Mejorar a Premium';

  @override
  String get iHaveCoupon => 'Tengo un cupón';

  @override
  String get enterCouponCode =>
      'Ingresa el código de cupón para obtener créditos gratis';

  @override
  String get enterCouponCodeTitle => 'Ingresa Código de Cupón';

  @override
  String get enterCouponCodeSubtitle =>
      'Ingresa el código de cupón que recibiste para obtener créditos gratis';

  @override
  String get couponCode => 'Código de cupón';

  @override
  String get mustEnterCoupon => 'Debes ingresar un código de cupón';

  @override
  String get couponActivated => '¡Cupón activado exitosamente!';

  @override
  String get errorRedeemingCoupon => 'Error al canjear cupón';

  @override
  String get redeemCoupon => 'Canjear Cupón';

  @override
  String creditsAddedToAccount(int count) {
    return '¡$count créditos añadidos a tu cuenta! 🎉';
  }

  @override
  String get contactUs => 'Contáctanos';

  @override
  String get contactSubtitle =>
      '¡Nos encantaría saber de ti! Completa los datos y te responderemos pronto.';

  @override
  String get phone => 'Teléfono';

  @override
  String get message => 'Mensaje';

  @override
  String get writeYourMessage => 'Escribe tu mensaje aquí...';

  @override
  String get enterPhoneOrEmail =>
      '* Por favor ingresa al menos teléfono o correo';

  @override
  String get pleaseEnterPhoneOrEmail =>
      'Por favor ingresa al menos teléfono o correo';

  @override
  String get pleaseEnterMessage => 'Por favor ingresa un mensaje';

  @override
  String get errorSendingMessage =>
      'Error al enviar mensaje. Por favor intenta de nuevo.';

  @override
  String get sendMessage => 'Enviar Mensaje';

  @override
  String get messageSentSuccess => '¡Mensaje enviado exitosamente!';

  @override
  String get contentNotAllowed => 'Contenido No Permitido';

  @override
  String get requestFailed => 'Solicitud Fallida';

  @override
  String get oopsSomethingWrong => '¡Ups! Algo salió mal';

  @override
  String get moderationError =>
      'No se puede procesar esta imagen o solicitud.\n\nLa imagen o solicitud puede contener contenido no permitido para procesamiento.\n\nIntenta con una imagen diferente o cambia la solicitud.';

  @override
  String get timeoutError =>
      'La solicitud tardó demasiado.\n\nPor favor intenta de nuevo más tarde.';

  @override
  String get genericError =>
      'No pudimos procesar la solicitud.\n\nIntenta de nuevo o contacta soporte si el problema persiste.';

  @override
  String get close => 'Cerrar';

  @override
  String get tryAgain => 'Intentar de Nuevo';

  @override
  String get imageSavedToGallery => '¡Imagen guardada en la galería!';

  @override
  String get errorDownloadingImage => 'Error al descargar imagen';

  @override
  String get errorSharing => 'Error al compartir';

  @override
  String get shareText =>
      '🏠 ¡Diseñé esto con MoomHe AI!\n📸 ¿Quieres probarlo también? https://moomhe.com';

  @override
  String get comparison => 'Comparación';

  @override
  String get download => 'Descargar';

  @override
  String get share => 'Compartir';

  @override
  String get revertToOriginal => 'Volver al Original';

  @override
  String get loveItSave => '¡Me encanta! Guardar';

  @override
  String get creditsFinishedThisMonth => 'Créditos agotados este mes';

  @override
  String get creditsRanOut => 'Créditos agotados este mes';

  @override
  String get freeLimitReached => 'Has alcanzado el límite de uso gratuito';

  @override
  String get reachedFreeLimit => 'Has alcanzado el límite de uso gratuito';

  @override
  String creditsLimitReached(int limit) {
    return 'Has alcanzado tu límite de créditos ($limit créditos). Puedes mejorar a un plan más grande o esperar hasta el próximo mes.';
  }

  @override
  String freeCreditsUsed(int limit) {
    return 'Has usado todos tus $limit créditos gratuitos. Para continuar diseñando sin límites y obtener funciones avanzadas, mejora a un plan profesional.';
  }

  @override
  String get currentUsage => 'Uso Actual';

  @override
  String get limit => 'Límite';

  @override
  String designs(int count) {
    return '$count diseños';
  }

  @override
  String designsCount(int count) {
    return '$count diseños';
  }

  @override
  String get upgradePlan => 'Mejorar Plan';

  @override
  String get goToProfessionalPlan => 'Ir a Plan Profesional';

  @override
  String get goPro => 'Ir a Pro';

  @override
  String get notNowThanks => 'No ahora, gracias';

  @override
  String welcomeToPlan(String planName) {
    return '¡Bienvenido al plan $planName!';
  }

  @override
  String get thankYouForJoining =>
      'Gracias por unirte a nuestra familia de suscriptores. Tu cuenta ha sido mejorada exitosamente y ahora tienes acceso a todas las funciones avanzadas y créditos adicionales.';

  @override
  String get creditsAddedToYourAccount => 'Créditos añadidos a tu cuenta';

  @override
  String get unlimitedStyleAccess => 'Acceso ilimitado a todos los estilos';

  @override
  String get supportCreators => 'Soporte para creadores y diseñadores';

  @override
  String get startDesigning => 'Empezar a Diseñar';

  @override
  String get secureYourSubscription => 'Asegura Tu Suscripción';

  @override
  String get secureSubscriptionMessage =>
      'Para no perder la suscripción que compraste, te recomendamos iniciar sesión con correo.\n\nAsí podrás restaurar tu suscripción en un nuevo dispositivo o después de reinstalar.';

  @override
  String get later => 'Más tarde';

  @override
  String get loginNow => 'Iniciar Sesión Ahora';

  @override
  String get onboardingUploadTitle => 'Subir Imagen';

  @override
  String get onboardingUploadDesc =>
      'Comienza subiendo una foto de la habitación que deseas diseñar. ¿No tienes una? No te preocupes, usaremos una imagen de ejemplo.';

  @override
  String get onboardingStyleTitle => 'Elegir Estilo de Rediseño';

  @override
  String get onboardingStyleDesc =>
      'Selecciona tu estilo preferido del menú lateral. Prueba \"Rediseñar\" para ver diferentes opciones.';

  @override
  String get onboardingCreateTitle => 'Crear Diseño';

  @override
  String get onboardingCreateDesc =>
      '¡Haz clic en \"Crear\" y la IA rediseñará tu habitación en segundos!';

  @override
  String get onboardingItemTipTitle => 'Consejo Extra: Añadir Objeto';

  @override
  String get onboardingItemTipDesc =>
      '¿Quieres añadir un mueble específico? Usa el botón \"Añadir Objeto\" para subir una imagen de un artículo e incorporarlo al diseño.';

  @override
  String get skip => 'Saltar';

  @override
  String get next => 'Siguiente';

  @override
  String get finish => 'Finalizar';

  @override
  String get promptAddedToInput =>
      'Prompt añadido - puedes editarlo y luego tocar Crear';

  @override
  String get styleMediterranean => 'Mediterráneo Moderno';

  @override
  String get styleWarmMinimalism => 'Minimalismo Cálido';

  @override
  String get styleBiophilic => 'Biofílico';

  @override
  String get styleModernLuxury => 'Lujo Moderno';

  @override
  String get styleJapandi => 'Japandi';

  @override
  String get styleScandinavian => 'Escandinavo';

  @override
  String get styleBohoChic => 'Boho Chic';

  @override
  String get styleIndustrial => 'Industrial';

  @override
  String get styleEarthyNatural => 'Natural Terroso';

  @override
  String get styleJerusalem => 'Jerusalén';

  @override
  String get styleMinimalist => 'Minimalista';

  @override
  String get styleModernClassic => 'Clásico Moderno';

  @override
  String get colorCategoryReds => 'Rojos';

  @override
  String get colorCategoryOranges => 'Naranjas';

  @override
  String get colorCategoryYellows => 'Amarillos';

  @override
  String get colorCategoryGreens => 'Verdes';

  @override
  String get colorCategoryBlues => 'Azules';

  @override
  String get colorCategoryPurples => 'Púrpuras';

  @override
  String get colorCategoryGrays => 'Grises';

  @override
  String get colorCategoryWhitesBlacks => 'Blancos y Negros';

  @override
  String get lightingRecessed => 'Iluminación Empotrada';

  @override
  String get lightingPendant => 'Lámpara Colgante';

  @override
  String get lightingChandelier => 'Araña';

  @override
  String get lightingTableLamp => 'Lámpara de Mesa';

  @override
  String get lightingFloorLamp => 'Lámpara de Pie';

  @override
  String get lightingWallSconce => 'Aplique de Pared';

  @override
  String get lightingTrack => 'Iluminación de Riel';

  @override
  String get lightingCeiling => 'Lámpara de Techo';

  @override
  String get lightingUnderCabinet => 'Iluminación Bajo Gabinete';

  @override
  String get lightingDecorative => 'Luces Decorativas';

  @override
  String get lightingDay => 'Día';

  @override
  String get lightingNight => 'Noche';

  @override
  String get lightingSunset => 'Atardecer';

  @override
  String get lightingSunrise => 'Amanecer';

  @override
  String get lightingAddRecessed => 'Añadir iluminación empotrada';

  @override
  String get lightingAddPendant => 'Añadir lámpara colgante';

  @override
  String get lightingAddChandelier => 'Añadir araña';

  @override
  String get lightingAddTableLamp => 'Añadir lámpara de mesa';

  @override
  String get lightingAddFloorLamp => 'Añadir lámpara de pie';

  @override
  String get lightingAddWallSconce => 'Añadir aplique de pared';

  @override
  String get lightingAddTrack => 'Añadir iluminación de riel';

  @override
  String get lightingAddCeiling => 'Añadir lámpara de techo';

  @override
  String get lightingAddUnderCabinet => 'Añadir iluminación bajo gabinete';

  @override
  String get lightingAddDecorative => 'Añadir luces decorativas';

  @override
  String get lightingChangeToDay => 'Cambiar iluminación a luz de día';

  @override
  String get lightingChangeToNight => 'Cambiar iluminación a luz de noche';

  @override
  String get lightingChangeToSunset => 'Cambiar iluminación a atardecer';

  @override
  String get lightingChangeToSunrise => 'Cambiar iluminación a amanecer';

  @override
  String get furnitureSofa => 'Sofá';

  @override
  String get furnitureSectional => 'Sofá Seccional';

  @override
  String get furnitureArmchair => 'Sillón';

  @override
  String get furnitureAccentChair => 'Silla Decorativa';

  @override
  String get furnitureDiningChair => 'Silla de Comedor';

  @override
  String get furnitureBarStool => 'Taburete';

  @override
  String get furnitureSingleBed => 'Cama Individual';

  @override
  String get furnitureDoubleBed => 'Cama Doble';

  @override
  String get furnitureBeanbag => 'Puf';

  @override
  String get furnitureOttoman => 'Otomana';

  @override
  String get furnitureBench => 'Banco';

  @override
  String get furnitureCoffeeTable => 'Mesa de Centro';

  @override
  String get furnitureEndTable => 'Mesa Auxiliar';

  @override
  String get furnitureNightstand => 'Mesita de Noche';

  @override
  String get furnitureDiningTable => 'Mesa de Comedor';

  @override
  String get furnitureDesk => 'Escritorio';

  @override
  String get furnitureDresser => 'Cómoda';

  @override
  String get furnitureWardrobe => 'Armario';

  @override
  String get furnitureBookcase => 'Estantería';

  @override
  String get furnitureTvStand => 'Mueble de TV';

  @override
  String get furnitureCabinets => 'Gabinetes de Cocina';

  @override
  String get furnitureAddSofa => 'Añadir sofá';

  @override
  String get furnitureAddSectional => 'Añadir sofá seccional';

  @override
  String get furnitureAddArmchair => 'Añadir sillón';

  @override
  String get furnitureAddAccentChair => 'Añadir silla decorativa';

  @override
  String get furnitureAddDiningChair => 'Añadir silla de comedor';

  @override
  String get furnitureAddBarStool => 'Añadir taburete';

  @override
  String get furnitureAddSingleBed => 'Añadir cama individual';

  @override
  String get furnitureAddDoubleBed => 'Añadir cama doble';

  @override
  String get furnitureAddBeanbag => 'Añadir puf';

  @override
  String get furnitureAddOttoman => 'Añadir otomana';

  @override
  String get furnitureAddBench => 'Añadir banco';

  @override
  String get furnitureAddCoffeeTable => 'Añadir mesa de centro';

  @override
  String get furnitureAddEndTable => 'Añadir mesa auxiliar';

  @override
  String get furnitureAddNightstand => 'Añadir mesita de noche';

  @override
  String get furnitureAddDiningTable => 'Añadir mesa de comedor';

  @override
  String get furnitureAddDesk => 'Añadir escritorio';

  @override
  String get furnitureAddDresser => 'Añadir cómoda';

  @override
  String get furnitureAddWardrobe => 'Añadir armario';

  @override
  String get furnitureAddBookcase => 'Añadir estantería';

  @override
  String get furnitureAddTvStand => 'Añadir mueble de TV';

  @override
  String get furnitureAddCabinets => 'Añadir gabinetes de cocina';

  @override
  String get repairsFixEverything => 'Arreglar todo';

  @override
  String get repairsRepairAll => 'Arreglar y reparar todo';

  @override
  String get repairsMessUp => 'Desordenar todo';

  @override
  String get repairsDestroy => 'Destruir y causar daños a todo';

  @override
  String get windowPicture => 'Ventana Fija';

  @override
  String get windowSliding => 'Ventana Corredera';

  @override
  String get windowCasement => 'Ventana Batiente';

  @override
  String get windowTiltTurn => 'Ventana Oscilobatiente';

  @override
  String get windowAwning => 'Ventana Toldo';

  @override
  String get windowSash => 'Ventana Guillotina';

  @override
  String get windowPocket => 'Ventana de Bolsillo';

  @override
  String get windowArched => 'Ventana en Arco';

  @override
  String get windowAddPicture => 'Añadir ventana panorámica grande';

  @override
  String get windowAddSliding => 'Añadir ventana corredera';

  @override
  String get windowAddCasement => 'Añadir ventana batiente';

  @override
  String get windowAddTiltTurn => 'Añadir ventana oscilobatiente';

  @override
  String get windowAddAwning => 'Añadir ventana toldo';

  @override
  String get windowAddSash => 'Añadir ventana guillotina';

  @override
  String get windowAddPocket => 'Añadir ventana de bolsillo';

  @override
  String get windowAddArched => 'Añadir ventana en arco';

  @override
  String get doorPocket => 'Puerta Corredera';

  @override
  String get doorFrench => 'Puertas Francesas';

  @override
  String get doorLouvered => 'Puerta de Persiana';

  @override
  String get doorBarn => 'Puerta de Granero';

  @override
  String get doorAddPocket => 'Añadir puerta corredera empotrada';

  @override
  String get doorAddFrench => 'Añadir puertas francesas con vidrio';

  @override
  String get doorAddLouvered => 'Añadir puerta de persiana';

  @override
  String get doorAddBarn => 'Añadir puerta de granero';

  @override
  String get toiletBidet => 'Bidé con Calefacción';

  @override
  String get toiletSeat => 'Asiento de Inodoro';

  @override
  String get tubFreestanding => 'Bañera Independiente';

  @override
  String get tubVintage => 'Bañera Vintage';

  @override
  String get tubStandard => 'Bañera Estándar';

  @override
  String get showerRain => 'Ducha de Lluvia';

  @override
  String get showerEnclosure => 'Cabina de Ducha';

  @override
  String get showerSliding => 'Puertas Correderas de Ducha';

  @override
  String get sinkPedestal => 'Lavabo de Pedestal';

  @override
  String get sinkStainless => 'Fregadero de Acero Inoxidable';

  @override
  String get sinkUndermount => 'Lavabo Bajo Encimera';

  @override
  String get jacuzziBuiltIn => 'Jacuzzi Empotrado';

  @override
  String get jacuzziPortable => 'Jacuzzi Portátil';

  @override
  String get poolInground => 'Piscina Enterrada';

  @override
  String get poolAboveGround => 'Piscina Elevada';

  @override
  String get toiletAddBidet => 'Añadir asiento con bidé';

  @override
  String get toiletAddSeat => 'Añadir asiento de inodoro';

  @override
  String get tubAddFreestanding => 'Añadir bañera independiente';

  @override
  String get tubAddVintage => 'Añadir bañera vintage';

  @override
  String get tubAddStandard => 'Añadir bañera estándar';

  @override
  String get showerAddRain => 'Añadir ducha con cabezal de lluvia';

  @override
  String get showerAddEnclosure => 'Añadir cabina de ducha';

  @override
  String get showerAddSliding => 'Añadir ducha con puertas correderas';

  @override
  String get sinkAddPedestal => 'Añadir lavabo de pedestal';

  @override
  String get sinkAddStainless => 'Añadir fregadero de acero';

  @override
  String get sinkAddUndermount => 'Añadir lavabo bajo encimera';

  @override
  String get jacuzziAddBuiltIn => 'Añadir jacuzzi empotrado';

  @override
  String get jacuzziAddPortable => 'Añadir jacuzzi portátil';

  @override
  String get poolAddInground => 'Añadir piscina enterrada';

  @override
  String get poolAddAboveGround => 'Añadir piscina elevada';

  @override
  String get errorUnknown => 'Error desconocido';

  @override
  String get searchWithLens => 'Buscar';

  @override
  String get cancelSearch => 'Cancelar';

  @override
  String get selectAreaToSearch =>
      'Dibuja un rectángulo alrededor del artículo que deseas buscar';

  @override
  String get searchingWithGoogleLens => 'Buscando con Google Lens...';

  @override
  String get selectAreaWithinImage =>
      'Por favor selecciona un área dentro de la imagen';

  @override
  String get googleLensSearchFailed => 'La búsqueda falló. Inténtalo de nuevo.';

  @override
  String get rateAppTitle => '¿Disfrutando la app?';

  @override
  String get rateAppMessage =>
      '¡Nos encantaría saber lo que piensas! Tu opinión nos ayuda a mejorar.';

  @override
  String get rateAppYes => '¡Sí, me encanta! 😍';

  @override
  String get rateAppNo => 'No realmente';

  @override
  String get rateAppLater => 'Pregúntame luego';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get deleteAccountWarning1Title => 'Eliminar Cuenta';

  @override
  String get deleteAccountWarning1Message =>
      '¿Estás seguro de que deseas eliminar tu cuenta? Esto eliminará toda tu información e imágenes y no se podrá deshacer.';

  @override
  String get deleteAccountWarning2Title => 'Confirmación Final';

  @override
  String get deleteAccountWarning2Message =>
      '¡Esta acción es irreversible! Todo tu historial e imágenes se eliminarán permanentemente. ¿Estás 100% seguro?';

  @override
  String get deleteAccountConfirm => 'Sí, Eliminar Cuenta';

  @override
  String get deletingAccount => 'Eliminando cuenta...';

  @override
  String get accountDeleted => 'Cuenta eliminada exitosamente';

  @override
  String get errorDeletingAccount => 'Error al eliminar la cuenta';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get languageChanged => 'Idioma cambiado';

  @override
  String get createAccountPromptTitle => 'Crea tu cuenta';

  @override
  String get createAccountPromptMessage =>
      '¡Actualizaciones increíbles llegarán en las próximas semanas! 🚀\n\nCrea una cuenta ahora para no perder tus creaciones y ser el primero en disfrutar de las nuevas funciones.';

  @override
  String get createAccountPromptButton => 'Crear cuenta';

  @override
  String get maybeLater => 'Quizás más tarde';

  @override
  String get readyDesigns => 'Galería de diseños';

  @override
  String get noCategories => 'Sin categorías';

  @override
  String get noDesigns => 'Sin diseños';

  @override
  String get noDesignsInCategory => 'No hay diseños en esta categoría';

  @override
  String get loadingDesigns => 'Cargando diseños...';

  @override
  String get loading => 'Cargando...';

  @override
  String get categoryKitchen => 'Cocina';

  @override
  String get categoryKidsBedroom => 'Dormitorio infantil';

  @override
  String get categoryBathroom => 'Baño';

  @override
  String get categoryLivingRoom => 'Sala de estar';

  @override
  String get categoryMasterBedroom => 'Dormitorio principal';

  @override
  String get useDesignQuestion => '¿Usar este diseño?';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get featureCarouselTitle1 => 'Diseño con IA';

  @override
  String get featureCarouselSubtitle1 => '✨ REDISEÑO INTELIGENTE';

  @override
  String get featureCarouselDesc1 =>
      'Transforma cualquier habitación con IA de vanguardia. Simplemente sube una foto y observa cómo tu espacio cobra vida con diseños profesionales.';

  @override
  String get featureCarouselTitle2 => 'Posibilidades Infinitas';

  @override
  String get featureCarouselSubtitle2 => '🎨 ESTILOS Y COLORES';

  @override
  String get featureCarouselDesc2 =>
      'Desde el minimalismo moderno hasta el bohemio acogedor — explora docenas de estilos de diseño y paletas de colores adaptadas a tu gusto.';

  @override
  String get featureCarouselTitle3 => 'Resultados Instantáneos';

  @override
  String get featureCarouselSubtitle3 => '⚡ SEGUNDOS, NO HORAS';

  @override
  String get featureCarouselDesc3 =>
      'Lo que antes tomaba horas a los diseñadores ahora sucede en segundos. Obtén transformaciones impresionantes de antes y después al instante.';

  @override
  String get getStarted => 'Comenzar';

  @override
  String freeTrialDays(int days) {
    return '$days días de prueba gratis';
  }

  @override
  String thenPrice(Object price) {
    return 'luego $price/mes';
  }
}
