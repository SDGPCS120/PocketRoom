export const MAX_IMAGES = 8;
export const MAX_IMAGE_BYTES = 5 * 1024 * 1024; // 5MB
export const ACCEPTED_IMAGE_TYPES = ['image/jpeg', 'image/jpg', 'image/png'];
export const MAX_MODEL_BYTES = 20 * 1024 * 1024; // 20MB

export interface AddProductFormData {
  name: string;
  description: string;
  furnitureType: string;
  price: string;
  width: string;
  height: string;
  depth: string;
  materials: string;
  styleTags: string;
}

export type FormErrors = Record<string, string>;

export const initialFormData: AddProductFormData = {
  name: '',
  description: '',
  furnitureType: 'Sofa',
  price: '',
  width: '',
  height: '',
  depth: '',
  materials: '',
  styleTags: '',
};

export function validateBasics(form: AddProductFormData): FormErrors {
  const errors: FormErrors = {};
  const name = form.name.trim();
  const description = form.description.trim();
  const price = Number(form.price);

  if (!name) {
    errors.name = 'Product name is required.';
  } else if (name.length < 3) {
    errors.name = 'Name must be at least 3 characters.';
  } else if (name.length > 100) {
    errors.name = 'Name must be 100 characters or fewer.';
  }

  if (!description) {
    errors.description = 'Description is required.';
  } else if (description.length < 20) {
    errors.description = 'Description must be at least 20 characters.';
  }

  if (!form.furnitureType) {
    errors.furnitureType = 'Category is required.';
  }

  if (form.price === '' || form.price == null) {
    errors.price = 'Price is required.';
  } else if (Number.isNaN(price) || price <= 0) {
    errors.price = 'Price must be greater than 0.';
  } else if (price > 100_000_000) {
    errors.price = 'Price seems too high. Please check the amount.';
  }

  return errors;
}

export function validateDetails(form: AddProductFormData): FormErrors {
  const errors: FormErrors = {};
  const { width, height, depth } = form;
  const anyDim = width !== '' || height !== '' || depth !== '';

  if (anyDim) {
    if (width === '' || height === '' || depth === '') {
      errors.dimensions = 'If you enter dimensions, please fill in width, height, and depth.';
    }
  }

  const checkNum = (key: 'width' | 'height' | 'depth', label: string) => {
    const val = form[key];
    if (val === '') return;
    const n = Number(val);
    if (Number.isNaN(n) || n < 0) {
      errors[key] = `${label} must be a positive number.`;
    }
  };

  checkNum('width', 'Width');
  checkNum('height', 'Height');
  checkNum('depth', 'Depth');

  return errors;
}

export function validateImageFile(file: File): string | null {
  if (!ACCEPTED_IMAGE_TYPES.includes(file.type)) {
    return `"${file.name}" must be a JPG or PNG image.`;
  }
  if (file.size > MAX_IMAGE_BYTES) {
    return `"${file.name}" exceeds the 5MB size limit.`;
  }
  return null;
}

export function validateModelFile(file: File | null): string | null {
  if (!file) return null;
  const name = file.name.toLowerCase();
  if (!name.endsWith('.glb') && !name.endsWith('.gltf')) {
    return `"${file.name}" must be a .glb or .gltf file.`;
  }
  if (file.size > MAX_MODEL_BYTES) {
    return `"${file.name}" exceeds the 20MB size limit for 3D models.`;
  }
  return null;
}

export function validateMedia(
  imageFiles: File[],
  generate3D: boolean,
  modelFile: File | null,
): FormErrors {
  const errors: FormErrors = {};

  if (generate3D && imageFiles.length === 0) {
    errors.images =
      'Upload at least one image to generate a 3D model, or uncheck “Generate 3D Model now”.';
  }
  
  if (generate3D && modelFile) {
    errors.model = 'You cannot both generate a 3D model and upload a custom one. Please choose one.';
  }

  if (imageFiles.length > MAX_IMAGES) {
    errors.images = `You can upload at most ${MAX_IMAGES} images.`;
  }

  for (const file of imageFiles) {
    const err = validateImageFile(file);
    if (err) {
      errors.images = err;
      break;
    }
  }

  const modelErr = validateModelFile(modelFile);
  if (modelErr) {
    errors.model = modelErr;
  }

  return errors;
}

export function validateStep(
  step: 1 | 2 | 3 | 4,
  form: AddProductFormData,
  imageFiles: File[],
  generate3D: boolean,
  modelFile: File | null,
): FormErrors {
  switch (step) {
    case 1:
      return validateBasics(form);
    case 2:
      return validateDetails(form);
    case 3:
      return validateMedia(imageFiles, generate3D, modelFile);
    case 4:
      return {
        ...validateBasics(form),
        ...validateDetails(form),
        ...validateMedia(imageFiles, generate3D, modelFile),
      };
    default:
      return {};
  }
}
