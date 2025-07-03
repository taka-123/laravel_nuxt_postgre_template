import { expect } from 'vitest'
import * as matchers from '@testing-library/jest-dom/matchers'

// @testing-library/jest-domのmatchersを拡張
expect.extend(matchers)
