module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/test/**/*.test.cjs'],
  collectCoverageFrom: [
    'src/**/*.cjs',
    '!src/**/*.test.cjs'
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  setupFilesAfterEnv: ['<rootDir>/test/setup.cjs'],
  clearMocks: true,
  restoreMocks: true
};