// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Loyalty';

  @override
  String get language => 'Idioma';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonCustomer => 'Cliente';

  @override
  String get commonPoints => 'puntos';

  @override
  String get commonPts => 'pts';

  @override
  String get navMyCard => 'Mi tarjeta';

  @override
  String get navRewards => 'Premios';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navScanner => 'Escáner';

  @override
  String get navVisits => 'Visitas';

  @override
  String get loginSubtitle => 'Inicia sesión en tu cuenta';

  @override
  String get loginInvalidCredentials => 'Correo o contraseña inválidos.';

  @override
  String get loginEmailLabel => 'Correo';

  @override
  String get loginEmailRequired => 'El correo es obligatorio';

  @override
  String get loginEmailInvalid => 'Ingresa un correo válido';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginPasswordRequired => 'La contraseña es obligatoria';

  @override
  String get loginSignInButton => 'Iniciar sesión';

  @override
  String get loginNoAccountPrefix => '¿No tienes una cuenta? ';

  @override
  String get loginSignUpLink => 'Regístrate';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerSubtitle => 'Únete a tu negocio favorito';

  @override
  String get registerFailed => 'No se pudo registrar. Inténtalo de nuevo.';

  @override
  String get registerBusinessCodeLabel => 'Código del negocio';

  @override
  String get registerBusinessCodeHint => 'ej. joes-barbershop';

  @override
  String get registerBusinessCodeRequired =>
      'El código del negocio es obligatorio';

  @override
  String get registerFirstNameLabel => 'Nombre';

  @override
  String get registerLastNameLabel => 'Apellido';

  @override
  String get registerFieldRequired => 'Obligatorio';

  @override
  String get registerEmailLabel => 'Correo';

  @override
  String get registerEmailRequired => 'El correo es obligatorio';

  @override
  String get registerEmailInvalid => 'Ingresa un correo válido';

  @override
  String get registerPhoneLabel => 'Teléfono (opcional)';

  @override
  String get registerPasswordLabel => 'Contraseña';

  @override
  String get registerPasswordRequired => 'La contraseña es obligatoria';

  @override
  String get registerPasswordTooShort => 'Al menos 6 caracteres';

  @override
  String get registerCreateAccountButton => 'Crear cuenta';

  @override
  String get registerHasAccountPrefix => '¿Ya tienes una cuenta? ';

  @override
  String get registerSignInLink => 'Iniciar sesión';

  @override
  String get cardTitle => 'Mi tarjeta';

  @override
  String get cardLoadError => 'No se pudo cargar tu tarjeta.';

  @override
  String get cardBusinessName => 'Club de fidelidad';

  @override
  String get cardMemberName => 'Miembro';

  @override
  String get cardRecentActivity => 'Actividad reciente';

  @override
  String get cardActivityLoadError =>
      'No se pudo cargar la actividad reciente.';

  @override
  String get cardNoActivity =>
      'Aún no hay actividad. ¡Visítanos para empezar a ganar puntos!';

  @override
  String get cardStatTotalPoints => 'Puntos totales';

  @override
  String get cardStatVisits => 'Visitas';

  @override
  String get cardStatMemberSince => 'Miembro desde';

  @override
  String cardTimeMinutesAgo(Object minutes) {
    return 'hace $minutes min';
  }

  @override
  String cardTimeHoursAgo(Object hours) {
    return 'hace $hours h';
  }

  @override
  String cardTimeDaysAgo(Object days) {
    return 'hace $days d';
  }

  @override
  String get loyaltyCardPointsLabel => 'PUNTOS';

  @override
  String get loyaltyCardMemberLabel => 'MIEMBRO';

  @override
  String get rewardsTitle => 'Premios';

  @override
  String get rewardsLoadError => 'No se pudieron cargar los premios.';

  @override
  String get rewardsEmpty => 'Aún no hay premios disponibles.';

  @override
  String get rewardLoadError => 'No se pudo cargar el premio.';

  @override
  String get rewardDetailTitle => 'Detalles del premio';

  @override
  String get rewardPointsLabel => 'puntos';

  @override
  String rewardRequiresTier(Object tier) {
    return 'Requiere nivel $tier';
  }

  @override
  String get rewardYourBalance => 'Tu saldo';

  @override
  String rewardBalancePts(Object points) {
    return '$points pts';
  }

  @override
  String rewardRedeemFor(Object points) {
    return 'Canjear por $points puntos';
  }

  @override
  String get rewardNotEnoughPoints => 'Puntos insuficientes';

  @override
  String rewardNotEnoughPointsCount(Object current, Object required) {
    return 'Puntos insuficientes ($current/$required)';
  }

  @override
  String rewardTierRequiredButton(Object tier) {
    return 'Requiere nivel $tier';
  }

  @override
  String rewardNeedMorePoints(Object points) {
    return 'Necesitas $points puntos más';
  }

  @override
  String get rewardRedeemedTitle => '¡Premio canjeado!';

  @override
  String get rewardRedeemedSubtitle =>
      'Muestra esto al personal para reclamar tu premio.';

  @override
  String get rewardTypeDiscount => 'Descuento';

  @override
  String get rewardTypeFreeItem => 'Artículo gratis';

  @override
  String get rewardTypeService => 'Servicio';

  @override
  String get rewardTypeMerchandise => 'Mercancía';

  @override
  String get rewardConfirmTitle => 'Canjear premio';

  @override
  String rewardConfirmMessage(Object points, Object name) {
    return '¿Gastar $points puntos para canjear \"$name\"?';
  }

  @override
  String get rewardRedeemSuccess => '¡Premio canjeado con éxito!';

  @override
  String get rewardRedeemFailure =>
      'No se pudo canjear el premio. Inténtalo de nuevo.';

  @override
  String get scannerLabel => 'Escanea el código QR del cliente';

  @override
  String get scannerCheckInTitle => 'Registrar cliente';

  @override
  String get scannerServiceLabel => 'Servicio';

  @override
  String get scannerAmountLabel => 'Monto (\$)';

  @override
  String get scannerCheckInButton => 'Registrar';

  @override
  String get scannerCheckInSuccessTitle => 'Registro exitoso';

  @override
  String scannerPointsAwarded(Object points) {
    return '+$points pts';
  }

  @override
  String get scannerScanNextButton => 'Escanear siguiente';

  @override
  String get scannerCheckInFailedTitle => 'Registro fallido';

  @override
  String get scannerTryAgainButton => 'Intentar de nuevo';

  @override
  String get visitsTitle => 'Visitas recientes';

  @override
  String get visitsEmptyTitle => 'Aún no hay visitas';

  @override
  String get visitsEmptyMessage =>
      'Las visitas registradas aparecerán aquí.\nEscanea el código QR de un cliente para empezar.';

  @override
  String get visitsToday => 'Hoy';

  @override
  String get visitsYesterday => 'Ayer';

  @override
  String visitsPointsEarned(Object points) {
    return '+$points pts';
  }

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileMember => 'Miembro';

  @override
  String get profileStaff => 'Personal';

  @override
  String get profileRoleOwner => 'Dueño';

  @override
  String get profileRoleManager => 'Gerente';

  @override
  String get profileRoleStaff => 'Personal';

  @override
  String get profileRoleCustomer => 'Cliente';

  @override
  String get profileSignOut => 'Cerrar sesión';

  @override
  String get profileSettings => 'Ajustes';

  @override
  String get profileNotifications => 'Notificaciones';

  @override
  String get profileHelpSupport => 'Ayuda y soporte';

  @override
  String get profileAbout => 'Acerca de';

  @override
  String get profilePointsHistory => 'Historial de puntos';

  @override
  String get profileHistoryLoadError => 'No se pudo cargar el historial.';

  @override
  String get profileNoTransactions => 'Aún no hay transacciones';

  @override
  String profileMemberSince(Object date) {
    return 'Miembro desde $date';
  }

  @override
  String profilePtsToTier(Object points, Object tier) {
    return '$points pts para $tier';
  }

  @override
  String get profileHighestTier => 'Nivel máximo alcanzado';

  @override
  String get profileTodaysActivity => 'Actividad de hoy';

  @override
  String get profileVisitsToday => 'Visitas hoy';

  @override
  String get profilePointsAwarded => 'Puntos otorgados';
}
