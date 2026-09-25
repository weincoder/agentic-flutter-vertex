import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Agentic Flutter + Vertex AI',
  tagline: 'Aprende a construir aplicaciones con agentes de IA en Flutter de la forma más simple',
  favicon: 'img/favicon.ico',

  url: 'https://weincoder.github.io',
  baseUrl: process.env.BASE_URL || '/agentic-flutter-vertex/',
  trailingSlash: false,

  organizationName: 'weincoder',
  projectName: 'agentic-flutter-vertex',

  onBrokenLinks: 'warn',

  i18n: {
    defaultLocale: 'es',
    locales: ['es', 'en'],
    localeConfigs: {
      es: {
        label: 'Español',
        direction: 'ltr',
        htmlLang: 'es-ES',
      },
      en: {
        label: 'English',
        direction: 'ltr',
        htmlLang: 'en-US',
      },
    },
  },

  markdown: {
    mermaid: true,
  },
  themes: ['@docusaurus/theme-mermaid'],

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/', // Serve docs directly at the root
          editUrl: undefined,
        },
        blog: false, // We focus strictly on documentation
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'img/docusaurus-social-card.jpg',
    colorMode: {
      defaultMode: 'dark',
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'Agentic Flutter',
      logo: {
        alt: 'VoiceFlow Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Guía / Guide',
        },
        {
          type: 'localeDropdown',
          position: 'right',
        },
        {
          href: 'https://github.com/weincoder/agentic-flutter-vertex',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Documentación',
          items: [
            {
              label: 'Introducción',
              to: '/',
            },
            {
              label: 'Conceptos Clave',
              to: '/core-concepts',
            },
            {
              label: 'Agente en Tiempo Real (Live)',
              to: '/live-agent',
            },
          ],
        },
        {
          title: 'Tecnologías',
          items: [
            {
              label: 'Flutter',
              href: 'https://flutter.dev',
            },
            {
              label: 'Google Cloud Vertex AI',
              href: 'https://cloud.google.com/vertex-ai',
            },
            {
              label: 'Firebase Vertex AI / firebase_ai',
              href: 'https://firebase.google.com/docs/vertex-ai',
            },
          ],
        },
        {
          title: 'Repositorio',
          items: [
            {
              label: 'Código en GitHub',
              href: 'https://github.com/weincoder/agentic-flutter-vertex',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} VoiceFlow Diary. Documentación creada para la comunidad de Flutter & IA.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['dart', 'bash', 'yaml', 'json'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
