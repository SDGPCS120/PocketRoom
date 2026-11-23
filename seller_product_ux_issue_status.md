# Seller product UX issue status

**Reviewed:** 23 November 2026  
**Scope:** Seller Add Product, Store Catalog, and related edit flow in the web frontend. This consolidates the issues in `seller_product_ux_polish_4a1e7198.plan.md` and `seller_product_ux_polish_82e13516.plan.md`. The plans list the same six tasks, with pending and completed labels respectively. Status below reflects the current application code rather than those labels.

**Status key:** Fixed = present in the active flow; Partially fixed = some requested behavior exists but a material part remains; Not fixed = the requested behavior is absent.

## Main issues

| Issue | Status | Current evidence and remaining work |
| --- | --- | --- |
| Catalog has no search, category filter, sorting, or product count | **Fixed** | [SellerProducts.tsx](frontend/web/src/components/SellerProducts.tsx) filters by text and category, sorts by name, price, or newest, and displays a filtered product count. Filtering runs on the products loaded for the store. |
| Add Product is one long form | **Fixed** | [App.tsx](frontend/web/src/App.tsx) routes `/add-product` to [AddProductWizard.tsx](frontend/web/src/components/add-product/AddProductWizard.tsx), which renders Basics, Details, Media, and Review steps. The older [SellerAddProduct.tsx](frontend/web/src/components/SellerAddProduct.tsx) remains in the repository but is not the routed page. |
| Catalog buttons and shared CSS tokens are missing | **Fixed** | [index.css](frontend/web/src/index.css) imports [shared.css](frontend/web/src/styles/shared.css). [buttons.css](frontend/web/src/styles/buttons.css) defines `btn-primary`, `btn-sm`, and `mt-4`; [tokens.css](frontend/web/src/styles/tokens.css) defines the shared color variables. |
| Catalog deletion uses browser alert and confirm dialogs | **Fixed** | [SellerProducts.tsx](frontend/web/src/components/SellerProducts.tsx) uses [ConfirmDialog.tsx](frontend/web/src/components/ConfirmDialog.tsx) for deletion and toast messages for success or errors. |
| Add Product has weak validation and generic API errors | **Fixed** | [useAddProductForm.ts](frontend/web/src/components/add-product/useAddProductForm.ts) validates each step, name, description, price, dimensions, image type, image count, image size, and optional model file. [AddProductWizard.tsx](frontend/web/src/components/add-product/AddProductWizard.tsx) gates Next and Publish, shows field errors, and uses `toUserFacingApiError`. |
| No customer preview before publishing | **Partially fixed** | [StepReview.tsx](frontend/web/src/components/add-product/StepReview.tsx) shows a catalog-style product card and review summary with links back to edit steps. It does not preview the mobile product page. |
| Catalog cards omit seller status details | **Partially fixed** | [SellerProducts.tsx](frontend/web/src/components/SellerProducts.tsx) shows image count, missing-image warning, and AR Ready badge. It does not show stock, last update time, or an explicit pending/failed 3D generation status. |
| Feedback differs between registration, Add Product, catalog, and edit | **Partially fixed** | Add Product has field errors, API error messages, loading steps, and a publish toast; the catalog uses toasts and a delete loading state. [SellerEditProduct.tsx](frontend/web/src/components/SellerEditProduct.tsx) still uses its own form and validation patterns. |
| Product may remain after image or model upload fails | **Not fixed** | [AddProductWizard.tsx](frontend/web/src/components/add-product/AddProductWizard.tsx) creates the product before uploading files. If a later upload fails, it shows a general error and returns without deleting the new product or presenting a recovery path. A 3D generation failure is separately reported by toast after the product is saved. |

## Deferred items from the plans

| Item | Status | Current evidence and remaining work |
| --- | --- | --- |
| Stock and inventory controls | **Not fixed** | [create-product.dto.ts](backend/src/modules/product/dto/create-product.dto.ts) has an optional `stock` field, but the active Add Product wizard has no stock input and the catalog does not display stock. |
| Product variants and color picker | **Not fixed** | The product DTO supports `colors`, but the active wizard and catalog provide no color or variant controls. |
| Categories loaded from the backend | **Not fixed** | [StepBasics.tsx](frontend/web/src/components/add-product/StepBasics.tsx) and the catalog use the fixed list in [categories.ts](frontend/web/src/constants/categories.ts); the edit page has its own hardcoded list. |
| Draft and publish workflow | **Not fixed** | [AddProductWizard.tsx](frontend/web/src/components/add-product/AddProductWizard.tsx) publishes directly. It has no Save as Draft action or listing status workflow. |
| Bulk edit or delete | **Not fixed** | [SellerProducts.tsx](frontend/web/src/components/SellerProducts.tsx) provides actions on individual cards only. |
| Catalog pagination | **Not fixed** | [product.service.ts](backend/src/modules/product/product.service.ts) reads all products for a store, and [SellerProducts.tsx](frontend/web/src/components/SellerProducts.tsx) renders the filtered list without page controls. |

## Verification

The current web frontend passed `npm run build` (`tsc -b` and Vite build) on 23 November 2026. Status is based on source inspection and compilation; interactive browser behavior and upload failure recovery were not tested.
