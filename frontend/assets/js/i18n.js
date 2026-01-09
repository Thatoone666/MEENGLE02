// Internationalization (i18n) System
class i18n {
  constructor(options = {}) {
    this.currentLocale = options.defaultLocale || 'en';
    this.supportedLocales = options.supportedLocales || ['en', 'es', 'fr', 'de', 'pt'];
    this.translations = options.translations || {};
    this.fallbackLocale = options.fallbackLocale || 'en';

    this.init();
  }

  init() {
    // Load saved locale from storage
    const saved = localStorage.getItem('locale');
    if (saved && this.supportedLocales.includes(saved)) {
      this.currentLocale = saved;
    }

    // Set document language
    document.documentElement.lang = this.currentLocale;
  }

  setLocale(locale) {
    if (!this.supportedLocales.includes(locale)) {
      console.warn(`Locale ${locale} not supported`);
      return;
    }

    this.currentLocale = locale;
    localStorage.setItem('locale', locale);
    document.documentElement.lang = locale;

    // Trigger UI update
    window.dispatchEvent(new CustomEvent('localeChange', { detail: { locale } }));
  }

  addTranslations(locale, translations) {
    if (!this.translations[locale]) {
      this.translations[locale] = {};
    }

    this.translations[locale] = {
      ...this.translations[locale],
      ...translations
    };
  }

  t(key, variables = {}) {
    let translation = this.getTranslation(key);

    if (!translation) {
      console.warn(`Translation not found: ${key}`);
      return key;
    }

    // Replace variables
    Object.entries(variables).forEach(([varKey, value]) => {
      translation = translation.replace(`{{${varKey}}}`, value);
    });

    return translation;
  }

  getTranslation(key) {
    const locale = this.currentLocale;
    const fallback = this.fallbackLocale;

    // Try current locale
    const current = this.getNestedValue(this.translations[locale], key);
    if (current) return current;

    // Try fallback locale
    const fallbackTranslation = this.getNestedValue(this.translations[fallback], key);
    if (fallbackTranslation) return fallbackTranslation;

    return null;
  }

  getNestedValue(obj, path) {
    return path.split('.').reduce((current, prop) => current?.[prop], obj);
  }

  getLocale() {
    return this.currentLocale;
  }

  getSupportedLocales() {
    return this.supportedLocales;
  }

  formatDate(date, format = 'short') {
    const options = {
      short: { year: 'numeric', month: 'short', day: 'numeric' },
      long: { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' },
      full: { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' }
    };

    return new Intl.DateTimeFormat(this.currentLocale, options[format]).format(new Date(date));
  }

  formatCurrency(amount, currency = 'USD') {
    return new Intl.NumberFormat(this.currentLocale, {
      style: 'currency',
      currency
    }).format(amount);
  }

  formatNumber(number) {
    return new Intl.NumberFormat(this.currentLocale).format(number);
  }

  formatList(items) {
    return new Intl.ListFormat(this.currentLocale).format(items);
  }

  pluralize(count, singular, plural) {
    return count === 1 ? singular : plural;
  }
}

// Translation Helper Directive
class TranslationHelper {
  static init() {
    // Translate elements with data-i18n attribute
    document.addEventListener('DOMContentLoaded', () => {
      this.translateDOM();
    });

    // Re-translate on locale change
    window.addEventListener('localeChange', () => {
      this.translateDOM();
    });
  }

  static translateDOM() {
    document.querySelectorAll('[data-i18n]').forEach(element => {
      const key = element.dataset.i18n;
      const variables = JSON.parse(element.dataset.i18nVars || '{}');
      element.textContent = window.i18n.t(key, variables);
    });

    document.querySelectorAll('[data-i18n-placeholder]').forEach(element => {
      const key = element.dataset.i18nPlaceholder;
      element.placeholder = window.i18n.t(key);
    });

    document.querySelectorAll('[data-i18n-title]').forEach(element => {
      const key = element.dataset.i18nTitle;
      element.title = window.i18n.t(key);
    });
  }
}

// Locale Switcher Component
class LocaleSwitcher {
  constructor(options = {}) {
    this.container = options.container;
    this.i18nInstance = options.i18n || window.i18n;
    this.render();
  }

  render() {
    if (!this.container) return;

    const currentLocale = this.i18nInstance.getLocale();
    const locales = this.i18nInstance.getSupportedLocales();

    let html = '<div class="locale-switcher">';
    html += '<label>Language: </label>';
    html += '<select class="locale-select">';

    locales.forEach(locale => {
      const label = this.getLocaleName(locale);
      html += `
        <option value="${locale}" ${locale === currentLocale ? 'selected' : ''}>
          ${label}
        </option>
      `;
    });

    html += '</select>';
    html += '</div>';

    this.container.innerHTML = html;
    this.setupEventListeners();
  }

  getLocaleName(locale) {
    const names = {
      en: 'English',
      es: 'Español',
      fr: 'Français',
      de: 'Deutsch',
      pt: 'Português'
    };

    return names[locale] || locale;
  }

  setupEventListeners() {
    const select = this.container?.querySelector('.locale-select');
    if (select) {
      select.addEventListener('change', (e) => {
        this.i18nInstance.setLocale(e.target.value);
        this.render();
      });
    }
  }
}

// Default translations
const defaultTranslations = {
  en: {
    'app.title': 'Meengle',
    'app.description': 'Meet your match',
    'button.login': 'Login',
    'button.signup': 'Sign Up',
    'button.logout': 'Logout',
    'button.save': 'Save',
    'button.cancel': 'Cancel',
    'button.delete': 'Delete',
    'button.edit': 'Edit',
    'button.search': 'Search',
    'button.like': 'Like',
    'button.pass': 'Pass',
    'button.chat': 'Chat',
    'message.loading': 'Loading...',
    'message.error': 'Something went wrong',
    'message.success': 'Success!',
    'message.notFound': 'Not found',
    'message.noMatches': 'No matches yet',
    'profile.name': 'Name',
    'profile.email': 'Email',
    'profile.age': 'Age',
    'profile.bio': 'Bio',
    'profile.location': 'Location',
    'settings.language': 'Language',
    'settings.privacy': 'Privacy',
    'settings.notifications': 'Notifications'
  },
  es: {
    'app.title': 'Meengle',
    'app.description': 'Encuentra tu pareja',
    'button.login': 'Iniciar sesión',
    'button.signup': 'Registrarse',
    'button.logout': 'Cerrar sesión',
    'button.save': 'Guardar',
    'button.cancel': 'Cancelar',
    'button.delete': 'Eliminar',
    'button.edit': 'Editar',
    'button.search': 'Buscar',
    'button.like': 'Me gusta',
    'button.pass': 'Pasar',
    'button.chat': 'Chat',
    'message.loading': 'Cargando...',
    'message.error': 'Algo salió mal',
    'message.success': '¡Éxito!',
    'message.notFound': 'No encontrado',
    'message.noMatches': 'Sin coincidencias aún',
    'profile.name': 'Nombre',
    'profile.email': 'Correo electrónico',
    'profile.age': 'Edad',
    'profile.bio': 'Bio',
    'profile.location': 'Ubicación',
    'settings.language': 'Idioma',
    'settings.privacy': 'Privacidad',
    'settings.notifications': 'Notificaciones'
  },
  fr: {
    'app.title': 'Meengle',
    'app.description': 'Trouvez votre correspondance',
    'button.login': 'Connexion',
    'button.signup': 'S\'inscrire',
    'button.logout': 'Déconnexion',
    'button.save': 'Enregistrer',
    'button.cancel': 'Annuler',
    'button.delete': 'Supprimer',
    'button.edit': 'Modifier',
    'button.search': 'Recherche',
    'button.like': 'J\'aime',
    'button.pass': 'Passer',
    'button.chat': 'Chat',
    'message.loading': 'Chargement...',
    'message.error': 'Une erreur s\'est produite',
    'message.success': 'Succès!',
    'message.notFound': 'Non trouvé',
    'message.noMatches': 'Pas encore de correspondances',
    'profile.name': 'Nom',
    'profile.email': 'Email',
    'profile.age': 'Âge',
    'profile.bio': 'Bio',
    'profile.location': 'Localisation',
    'settings.language': 'Langue',
    'settings.privacy': 'Intimité',
    'settings.notifications': 'Notifications'
  }
};

// Initialize i18n system
const i18nInstance = new i18n({
  defaultLocale: 'en',
  supportedLocales: ['en', 'es', 'fr', 'de', 'pt'],
  translations: defaultTranslations
});

window.i18n = i18nInstance;
window.LocaleSwitcher = LocaleSwitcher;
window.TranslationHelper = TranslationHelper;

// Initialize translation helper
TranslationHelper.init();

export { i18n, LocaleSwitcher, TranslationHelper, defaultTranslations };
